import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:peyvand/services/api_service.dart';
import 'package:peyvand/features/profile/domain/models/user_model.dart';
import 'package:peyvand/features/profile/data/services/user_service.dart';
import 'package:peyvand/errors/api_exception.dart';


class EditProfileScreen extends StatefulWidget {
  final User user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _bioController;
  late TextEditingController _universityController;
  late TextEditingController _skillsController;
  late TextEditingController _studentCodeController;

  final UserService _userService = UserService();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  File? _selectedImageFile;
  String? _selectedImageMimeType;
  final ImagePicker _picker = ImagePicker();
  String? _currentProfilePictureRelativeUrl;
  int? _currentProfileFileId;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _bioController = TextEditingController(text: widget.user.bio);
    _universityController = TextEditingController(text: widget.user.university);
    _skillsController = TextEditingController(text: widget.user.skills?.join(', '));
    _currentProfilePictureRelativeUrl = widget.user.profilePictureRelativeUrl;
    _currentProfileFileId = widget.user.profileFileId;
    _studentCodeController = TextEditingController(text: widget.user.studentCode);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    _universityController.dispose();
    _skillsController.dispose();
    _studentCodeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 70, maxWidth: 1024, maxHeight: 1024);

      if (pickedFile != null) {
        String? determinedMimeType = pickedFile.mimeType;
        print('MIME type directly from image_picker: $determinedMimeType');

        if (determinedMimeType == null || determinedMimeType.isEmpty) {
          determinedMimeType = lookupMimeType(pickedFile.path);
          print('MIME type from lookupMimeType fallback: $determinedMimeType');
        }

        if (determinedMimeType == null || !determinedMimeType.startsWith('image/')) {
          print('Could not determine a valid image MIME type. Path: ${pickedFile.path}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('نوع فایل انتخاب شده قابل تشخیص نیست یا یک تصویر معتبر نمی‌باشد.')),
            );
          }
          return;
        }

        setState(() {
          _selectedImageFile = File(pickedFile.path);
          _selectedImageMimeType = determinedMimeType;
          print('Final selected image MIME type: $_selectedImageMimeType');
        });
      }
    } catch (e) {
      if(mounted) {
        print('Error picking image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در انتخاب تصویر: ')),
        );
      }
    }
  }


  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library_outlined),
                    title: const Text('گالری تصاویر'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _pickImage(ImageSource.gallery);
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('دوربین'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                if (_currentProfilePictureRelativeUrl != null || _selectedImageFile != null)
                  ListTile(
                    leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                    title: Text('حذف عکس فعلی', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    onTap: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _selectedImageFile = null;
                        _selectedImageMimeType = null;
                        _currentProfilePictureRelativeUrl = null;
                      });
                    },
                  ),
              ],
            ),
          );
        }
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() { _isLoading = true; });

    int? newProfileFileId = _currentProfileFileId;
    bool removeProfilePic = false;
    String? errorMessage;

    if (_selectedImageFile != null && _selectedImageMimeType != null) {
      try {
        final uploadData = await _userService.uploadProfileImageAndGetData(_selectedImageFile!, _selectedImageMimeType!);
        newProfileFileId = uploadData['id'];
      } on ApiException catch (e) {
        errorMessage = 'خطا در آپلود تصویر:\n${e.toString()}';
      } catch (e) {
        errorMessage = '$e';
      }

      if (errorMessage != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage!), backgroundColor: Theme.of(context).colorScheme.error, duration: const Duration(seconds: 5)),
          );
          setState(() { _isLoading = false; });
        }
        return;
      }
    } else if (_selectedImageFile == null && _currentProfilePictureRelativeUrl == null && widget.user.profileFileId != null) {
      removeProfilePic = true;
      newProfileFileId = null;
    }

    try {
      final String firstName = _firstNameController.text.trim();
      final String lastName = _lastNameController.text.trim();
      final String bio = _bioController.text.trim();
      final String university = _universityController.text.trim();
      final List<String> skills = _skillsController.text.trim().split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      final String studentCode = _studentCodeController.text.trim();

      bool profileDataChanged = firstName != (widget.user.firstName ?? '') ||
          lastName != (widget.user.lastName ?? '') ||
          bio != (widget.user.bio ?? '') ||
          university != (widget.user.university ?? '') ||
          studentCode != (widget.user.studentCode ?? '') ||
          !_listEquals(skills, widget.user.skills ?? []) ||
          (removeProfilePic && widget.user.profileFileId != null) ||
          (newProfileFileId != null && newProfileFileId != widget.user.profileFileId && !removeProfilePic) ||
          (newProfileFileId == null && widget.user.profileFileId != null && removeProfilePic);

      if (!profileDataChanged) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('هیچ تغییری برای ذخیره وجود ندارد.')),
          );
          setState(() { _isLoading = false; });
        }
        return;
      }

      await _userService.updateUserProfile(
        userId: widget.user.id,
        firstName: firstName,
        lastName: lastName,
        bio: bio,
        profileFileId: newProfileFileId,
        removeProfileFile: removeProfilePic,
        university: university.isNotEmpty ? university : null,
        skills: skills.isNotEmpty ? skills : null,
        studentCode: studentCode.isNotEmpty ? studentCode : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('پروفایل با موفقیت ذخیره شد.'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true);
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در ذخیره پروفایل:\n${e.toString()}'), backgroundColor: Theme.of(context).colorScheme.error, duration: const Duration(seconds: 5)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Theme.of(context).colorScheme.error, duration: const Duration(seconds: 5)),
        );
      }
    }
    finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    if (a.isEmpty && b.isEmpty) return true;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    String displayImageUrl;

    if (_selectedImageFile != null) {
      displayImageUrl = '';
    } else if (_currentProfilePictureRelativeUrl != null && _currentProfilePictureRelativeUrl!.isNotEmpty) {
      displayImageUrl = _apiService.getBaseUrl() + _currentProfilePictureRelativeUrl!;
    } else {
      displayImageUrl = '';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ویرایش پروفایل'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3)),
            )
          else
            IconButton(
              icon: const Icon(Icons.save_alt_rounded),
              onPressed: _saveProfile,
              tooltip: 'ذخیره تغییرات',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      backgroundImage: _selectedImageFile != null
                          ? FileImage(_selectedImageFile!)
                          : (displayImageUrl.isNotEmpty
                          ? NetworkImage(displayImageUrl)
                          : null) as ImageProvider?,
                      child: (_selectedImageFile == null && displayImageUrl.isEmpty)
                          ? Icon(Icons.person_add_alt_1_rounded, size: 80, color: colorScheme.onSurfaceVariant)
                          : null,
                    ),
                    Material(
                      color: colorScheme.primary,
                      shape: const CircleBorder(),
                      elevation: 2,
                      child: InkWell(
                        onTap: () => _showImageSourceActionSheet(context),
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.edit_rounded, color: colorScheme.onPrimary, size: 22),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'نام',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (value) {
                  return null;
                },
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'نام خانوادگی',
                  prefixIcon: Icon(Icons.people_alt_outlined),
                ),
                validator: (value) {
                  return null;
                },
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: _studentCodeController,
                decoration: const InputDecoration(
                  labelText: 'کد دانشجویی',
                  prefixIcon: Icon(Icons.qr_code_scanner_rounded),
                ),
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'بیوگرافی',
                  hintText: 'چند کلمه درباره خودتان بنویسید...',
                  prefixIcon: Icon(Icons.article_outlined),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                maxLength: 200,
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: _universityController,
                decoration: const InputDecoration(
                  labelText: 'دانشگاه',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: _skillsController,
                decoration: const InputDecoration(
                  labelText: 'مهارت‌ها',
                  hintText: 'مهارت‌های خود را با کاما (,) جدا کنید',
                  prefixIcon: Icon(Icons.psychology_outlined),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: _isLoading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                    : const Text('ذخیره تغییرات'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}