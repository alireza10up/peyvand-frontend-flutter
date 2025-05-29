import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:peyvand/features/posts/data/models/post_model.dart';
import 'package:peyvand/features/posts/data/models/post_status_enum.dart';
import 'package:peyvand/features/posts/data/services/post_service.dart';
import 'package:peyvand/services/ai_service.dart';
import 'package:peyvand/errors/api_exception.dart';
import 'package:peyvand/services/api_service.dart';

class CreateEditPostScreen extends StatefulWidget {
  final Post? post;
  final VoidCallback? onPostSaved;
  static const String routeName = '/create-edit-post';

  const CreateEditPostScreen({super.key, this.post, this.onPostSaved});

  @override
  State<CreateEditPostScreen> createState() => _CreateEditPostScreenState();
}

class _CreateEditPostScreenState extends State<CreateEditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  PostStatus? _selectedStatus;

  final PostService _postService = PostService();
  final AiService _aiService = AiService();
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  List<File> _selectedImages = [];
  List<String> _selectedImageMimeTypes = [];
  List<PostFile> _initialPostFiles = [];

  bool _isLoading = false;
  final int _maxImages = 10;

  bool get _isEditMode => widget.post != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post?.title ?? '');
    _contentController = TextEditingController(
      text: widget.post?.content ?? '',
    );
    if (_isEditMode) {
      _selectedStatus = widget.post!.status;
      if (widget.post!.files.isNotEmpty) {
        _initialPostFiles = List<PostFile>.from(widget.post!.files);
      }
    }
    // In create mode, _selectedStatus remains null as user won't set it.
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isEditMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('در حالت ویرایش امکان تغییر تصاویر وجود ندارد.'),
        ),
      );
      return;
    }

    if (_selectedImages.length >= _maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('شما تنها قادر به انتخاب $_maxImages تصویر هستید.'),
        ),
      );
      return;
    }

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        String? determinedMimeType =
            pickedFile.mimeType ?? lookupMimeType(pickedFile.path);
        if (determinedMimeType == null ||
            !determinedMimeType.startsWith('image/')) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('فایل انتخاب شده یک تصویر معتبر نیست.'),
              ),
            );
          }
          return;
        }
        setState(() {
          _selectedImages.add(File(pickedFile.path));
          _selectedImageMimeTypes.add(determinedMimeType!);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطا در انتخاب تصویر: $e')));
      }
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    if (_isEditMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('در حالت ویرایش امکان افزودن تصویر جدید وجود ندارد.'),
        ),
      );
      return;
    }
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
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('دوربین'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _enhanceTextWithAI() async {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ابتدا متنی برای بهبود بنویسید.')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final enhancedText = await _aiService.enhancePost(
        _contentController.text,
      );
      if (mounted) {
        setState(() {
          _contentController.text = enhancedText;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در بهبود متن با هوش مصنوعی: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _generateImageWithAI() async {
    if (_isEditMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('در حالت ویرایش امکان تولید تصویر جدید وجود ندارد.'),
        ),
      );
      return;
    }
    if (_selectedImages.length >= _maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('به حداکثر تعداد تصاویر رسیده‌اید.')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'قابلیت تولید تصویر با هوش مصنوعی هنوز پیاده‌سازی نشده است.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در تولید تصویر با هوش مصنوعی: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _savePost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // In edit mode, status must be selected (it's initialized from current post's status)
    if (_isEditMode && _selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفاً وضعیت پست را مشخص کنید.')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      String? titleValue = _titleController.text.trim();
      if (titleValue.isEmpty) {
        titleValue = null;
      }

      if (!_isEditMode) {
        // Create new post
        // Status is not sent on create, server assigns default
        await _postService.createPost(
          title: titleValue,
          content: _contentController.text.trim(),
          images: _selectedImages,
          imageMimeTypes: _selectedImageMimeTypes,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('پست با موفقیت ایجاد شد.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Edit existing post
        await _postService.updatePost(
          postId: widget.post!.id,
          title: titleValue,
          content: _contentController.text.trim(),
          status: _selectedStatus, // Send the selected status for update
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('پست با موفقیت به‌روزرسانی شد.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      if (mounted) {
        widget.onPostSaved?.call();
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      if (_isEditMode) {
        Navigator.of(context).pop();
      }

      _resetForm();
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _contentController.clear();
    setState(() {
      _selectedImages.clear();
      _selectedImageMimeTypes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'ویرایش پست' : 'ایجاد پست جدید'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save_alt_rounded),
              onPressed: _savePost,
              tooltip: 'ذخیره پست',
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
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان پست (اختیاری)',
                  prefixIcon: Icon(Icons.title_rounded),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'محتوای پست',
                  hintText: 'چه چیزی در ذهن دارید؟',
                  prefixIcon: const Icon(Icons.article_outlined),
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                  suffixIcon: Tooltip(
                    message: "بهبود متن با AI",
                    child: IconButton(
                      icon: Icon(
                        Icons.auto_awesome_rounded,
                        color: colorScheme.secondary,
                      ),
                      onPressed: _enhanceTextWithAI,
                    ),
                  ),
                ),
                maxLines: 5,
                maxLength: 2000,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'محتوای پست نمی‌تواند خالی باشد.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),

              // Dropdown for post status, only shown in edit mode
              if (_isEditMode)
                DropdownButtonFormField<PostStatus>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'تغییر وضعیت پست',
                    prefixIcon: Icon(Icons.flag_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items:
                      PostStatus.values.map((PostStatus status) {
                        String statusText;
                        switch (status) {
                          case PostStatus.published:
                            statusText = 'انتشار';
                            break;
                          case PostStatus.draft:
                            statusText = 'پیش نویس';
                            break;
                          case PostStatus.archived:
                            statusText = 'آرشیو';
                            break;
                        }
                        return DropdownMenuItem<PostStatus>(
                          value: status,
                          child: Text(statusText),
                        );
                      }).toList(),
                  onChanged: (PostStatus? newValue) {
                    setState(() {
                      _selectedStatus = newValue;
                    });
                  },
                  validator:
                      (value) =>
                          value == null
                              ? 'لطفا وضعیت پست را انتخاب کنید'
                              : null,
                ),
              if (_isEditMode) const SizedBox(height: 22),

              // Image selection section, only shown in create mode
              if (!_isEditMode) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'تصاویر (${_selectedImages.length}/$_maxImages)',
                      style: textTheme.titleMedium,
                    ),
                    Row(
                      children: [
                        Tooltip(
                          message: "افزودن تصویر از دستگاه",
                          child: IconButton(
                            icon: Icon(
                              Icons.add_photo_alternate_outlined,
                              color: colorScheme.primary,
                              size: 28,
                            ),
                            onPressed:
                                () => _showImageSourceActionSheet(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Tooltip(
                          message: "تولید تصویر با AI (به زودی)",
                          child: IconButton(
                            icon: Icon(
                              Icons.palette_outlined,
                              color: colorScheme.secondary,
                              size: 28,
                            ),
                            onPressed: _generateImageWithAI,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildImagePickerGridForCreateMode(),
              ] else if (_isEditMode && _initialPostFiles.isNotEmpty) ...[
                // Display existing images in edit mode (non-editable)
                Text(
                  'تصاویر پیوست شده (غیرقابل تغییر):',
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                _buildExistingImagesGrid(),
              ],
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.save_rounded),
                label: Text(_isEditMode ? 'ذخیره تغییرات' : 'ایجاد پست'),
                onPressed: _isLoading ? null : _savePost,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickerGridForCreateMode() {
    if (_selectedImages.isEmpty) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported_outlined,
                size: 40,
                color: Colors.grey.shade600,
              ),
              const SizedBox(height: 8),
              Text(
                'هیچ تصویری انتخاب نشده است.',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _selectedImages.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        return Stack(
          alignment: Alignment.topLeft,
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.file(_selectedImages[index], fit: BoxFit.cover),
              ),
            ),
            // Show delete button only in create mode
            if (!_isEditMode)
              Container(
                margin: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedImages.removeAt(index);
                      _selectedImageMimeTypes.removeAt(index);
                    });
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildExistingImagesGrid() {
    if (_initialPostFiles.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _initialPostFiles.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final postFile = _initialPostFiles[index];
        final imageUrl =
            (_apiService.getBaseUrl() +
                (postFile.url.startsWith('/')
                    ? postFile.url
                    : '/${postFile.url}'));
        return ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) => Container(
                  color: Colors.grey.shade300,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.grey,
                  ),
                ),
            loadingBuilder: (
              BuildContext context,
              Widget child,
              ImageChunkEvent? loadingProgress,
            ) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey.shade200,
                child: Center(
                  child: CircularProgressIndicator(
                    value:
                        loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
