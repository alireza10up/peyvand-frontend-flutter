import 'package:flutter/material.dart';
import 'package:peyvand/config/app_theme.dart';
import 'package:peyvand/config/routes.dart';
import 'package:peyvand/ui/widgets/common/custom_button.dart';
import 'package:peyvand/ui/widgets/common/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate registration
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });
        Navigator.pushReplacementNamed(context, Routes.home);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.primaryColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ایجاد حساب کاربری',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'به جامعه حرفه‌ای ما بپیوندید',
                  style: TextStyle(
                    color: AppTheme.lightTextColor,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 32),
                // Name field
                CustomTextField(
                  label: 'نام و نام خانوادگی',
                  hintText: 'نام و نام خانوادگی خود را وارد کنید',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفا نام خود را وارد کنید';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                // Email field
                CustomTextField(
                  label: 'ایمیل',
                  hintText: 'ایمیل خود را وارد کنید',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفا ایمیل خود را وارد کنید';
                    }
                    if (!value.contains('@')) {
                      return 'لطفا یک ایمیل معتبر وارد کنید';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                // Password field
                CustomTextField(
                  label: 'رمز عبور',
                  hintText: 'یک رمز عبور ایجاد کنید',
                  controller: _passwordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفا رمز عبور را وارد کنید';
                    }
                    if (value.length < 6) {
                      return 'رمز عبور باید حداقل ۶ کاراکتر باشد';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                // Confirm Password field
                CustomTextField(
                  label: 'تایید رمز عبور',
                  hintText: 'رمز عبور خود را تایید کنید',
                  controller: _confirmPasswordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفا رمز عبور خود را تایید کنید';
                    }
                    if (value != _passwordController.text) {
                      return 'رمزهای عبور مطابقت ندارند';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                // Terms and conditions
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'با ثبت نام، شما با قوانین استفاده از خدمات و سیاست حفظ حریم خصوصی ما موافقت می‌کنید',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.lightTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                // Register button
                CustomButton(
                  text: 'ایجاد حساب کاربری',
                  isLoading: _isLoading,
                  onPressed: _register,
                ),
                SizedBox(height: 16),
                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("قبلاً حساب کاربری دارید؟"),
                    SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'ورود',
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
          ),
        ),
      ),
    );
  }
}