import 'package:flutter/material.dart';
import 'package:peyvand/services/api_service.dart'; // برای getBaseUrl
import 'package:peyvand/features/auth/presentation/screens/auth_screen.dart';
import 'package:peyvand/features/profile/data/models/user_model.dart';
import 'package:peyvand/features/profile/data/services/user_service.dart';
import 'package:peyvand/features/auth/data/services/auth_service.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  User? _user;
  bool _isLoading = true;
  String? _fullProfileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (!mounted) return;
    setState(() { _isLoading = true; });
    try {
      final user = await _userService.fetchUserProfile();
      if (mounted) {
        String? tempFullUrl;
        if (user.profilePictureRelativeUrl != null && user.profilePictureRelativeUrl!.startsWith('/')) {
          tempFullUrl = _apiService.getBaseUrl() + user.profilePictureRelativeUrl!;
        }
        setState(() {
          _user = user;
          _fullProfileImageUrl = tempFullUrl;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
            (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('پروفایل من'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: _logout,
            tooltip: 'خروج از حساب',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
          ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('اطلاعات پروفایل یافت نشد.', style: textTheme.titleMedium),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: _loadUserProfile, child: const Text('تلاش مجدد'))
            ],
          )
      )
          : RefreshIndicator(
        onRefresh: _loadUserProfile,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: colorScheme.surfaceContainerHighest,
                backgroundImage: _fullProfileImageUrl != null && _fullProfileImageUrl!.isNotEmpty
                    ? NetworkImage(_fullProfileImageUrl!)
                    : null,
                child: (_fullProfileImageUrl == null || _fullProfileImageUrl!.isEmpty)
                    ? Icon(
                  Icons.person_outline_rounded,
                  size: 70,
                  color: colorScheme.onSurfaceVariant,
                )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                _user!.displayName ?? _user!.email,
                style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            if (_user!.email.isNotEmpty)
              Center(
                child: Text(
                  _user!.email,
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ),
            const SizedBox(height: 24),

            if (_user!.firstName != null || _user!.lastName != null)
              _buildProfileInfoTile(
                context,
                icon: Icons.badge_outlined,
                title: 'نام کامل',
                value: ('${_user!.firstName ?? ''} ${_user!.lastName ?? ''}').trim(),
              ),
            _buildProfileInfoTile(
              context,
              icon: Icons.code_outlined, // Student Code
              title: 'کد دانشجویی',
              value: _user!.studentCode ?? '-',
            ),
            if (_user!.bio != null && _user!.bio!.isNotEmpty)
              _buildProfileInfoTile(
                context,
                icon: Icons.info_outline_rounded,
                title: 'بیوگرافی',
                value: _user!.bio!,
                isMultiline: true,
              ),
            if (_user!.university != null && _user!.university!.isNotEmpty)
              _buildProfileInfoTile(
                context,
                icon: Icons.school_outlined,
                title: 'دانشگاه',
                value: _user!.university!,
              ),
            if (_user!.skills != null && _user!.skills!.isNotEmpty)
              _buildProfileInfoTile(
                context,
                icon: Icons.lightbulb_outline_rounded,
                title: 'مهارت‌ها',
                value: _user!.skills!.join('، '),
                isMultiline: true,
              ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12)
              ),
              icon: const Icon(Icons.edit_note_rounded),
              label: const Text('ویرایش پروفایل'),
              onPressed: () async {
                final result = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(user: _user!),
                  ),
                );
                if (result == true && mounted) {
                  _loadUserProfile();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String value,
        bool isMultiline = false,
      }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal:16.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colorScheme.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.labelLarge?.copyWith( //labelLarge for title
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value.isEmpty ? '-' : value,
                    style: textTheme.bodyLarge?.copyWith(
                        height: isMultiline ? 1.4 : 1.2,
                        fontWeight: FontWeight.w500
                    ),
                    softWrap: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}