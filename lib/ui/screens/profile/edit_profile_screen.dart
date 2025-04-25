import 'package:flutter/material.dart';
import 'package:peyvand/config/app_theme.dart';
import 'package:peyvand/ui/widgets/common/custom_button.dart';
import 'package:peyvand/ui/widgets/common/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _aboutController = TextEditingController();
  final _skillsController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize with user data
    _nameController.text = 'جان دو';
    _titleController.text = 'مهندس نرم‌افزار ارشد';
    _companyController.text = 'شرکت نوآوری‌های فناوری';
    _locationController.text = 'تهران، ایران';
    _aboutController.text = 'مهندس نرم‌افزار با اشتیاق و بیش از ۸ سال تجربه در توسعه برنامه‌های مقیاس‌پذیر. متخصص در توسعه موبایل و ادغام هوش مصنوعی.';
    _skillsController.text = 'فلاتر، ری‌اکت نیتیو، یادگیری ماشین، پایتون، جاوااسکریپت، نود.جی‌اس، فایربیس، AWS، طراحی رابط کاربری';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _aboutController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('پروفایل با موفقیت به‌روزرسانی شد'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ویرایش پروفایل',
          style: TextStyle(
            color: AppTheme.secondaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.secondaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            )
                : Text(
              'ذخیره',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileImageSection(),
              SizedBox(height: 24),
              Text(
                'اطلاعات اصلی',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryColor,
                ),
              ),
              SizedBox(height: 16),
              CustomTextField(
                label: 'نام کامل',
                hintText: 'نام کامل خود را وارد کنید',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'لطفاً نام خود را وارد کنید';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CustomTextField(
                label: 'عنوان حرفه‌ای',
                hintText: 'عنوان حرفه‌ای خود را وارد کنید',
                controller: _titleController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'لطفاً عنوان خود را وارد کنید';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CustomTextField(
                label: 'شرکت',
                hintText: 'نام شرکت خود را وارد کنید',
                controller: _companyController,
              ),
              SizedBox(height: 16),
              CustomTextField(
                label: 'موقعیت مکانی',
                hintText: 'موقعیت مکانی خود را وارد کنید',
                controller: _locationController,
              ),
              SizedBox(height: 24),
              Text(
                'درباره',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryColor,
                ),
              ),
              SizedBox(height: 16),
              CustomTextField(
                label: 'بیوگرافی',
                hintText: 'درباره خودتان به ما بگویید',
                controller: _aboutController,
                maxLines: 5,
              ),
              SizedBox(height: 24),
              Text(
                'مهارت‌ها',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryColor,
                ),
              ),
              SizedBox(height: 16),
              CustomTextField(
                label: 'مهارت‌ها (با کاما جدا شده)',
                hintText: 'مهارت‌های خود را وارد کنید، با کاما جدا شده',
                controller: _skillsController,
              ),
              SizedBox(height: 24),
              _buildAiSuggestion(),
              SizedBox(height: 40),
              CustomButton(
                text: 'ذخیره پروفایل',
                isLoading: _isLoading,
                onPressed: _saveProfile,
              ),
              SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    // Show delete account confirmation
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('حذف حساب کاربری'),
                        content: Text('آیا مطمئن هستید که می‌خواهید حساب کاربری خود را حذف کنید؟ این عمل قابل بازگشت نیست.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('لغو'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              // Delete account logic here
                            },
                            child: Text(
                              'حذف',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    'حذف حساب کاربری',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  'JD',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'تغییر عکس پروفایل',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiSuggestion() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: AppTheme.primaryColor,
              ),
              SizedBox(width: 8),
              Text(
                'پیشنهاد هوش مصنوعی',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'بر اساس پروفایل شما، افزودن "معماری اپلیکیشن موبایل" و "رهبری تیم" به مهارت‌های شما می‌تواند قابلیت کشف پروفایل شما را تا ۳۰٪ افزایش دهد.',
            style: TextStyle(
              color: AppTheme.secondaryColor,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  // Add suggested skills
                  final currentSkills = _skillsController.text;
                  _skillsController.text = '$currentSkills، معماری اپلیکیشن موبایل، رهبری تیم';
                },
                child: Text(
                  'افزودن مهارت‌های پیشنهادی',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}