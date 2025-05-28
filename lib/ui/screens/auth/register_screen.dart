import 'package:flutter/material.dart';
import 'package:peyvand/config/routes.dart';
import 'package:peyvand/core/providers/auth_provider.dart';
import 'package:peyvand/ui/widgets/common/custom_button.dart';
import 'package:peyvand/ui/widgets/common/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:peyvand/config/app_theme.dart'; // برای دسترسی به AppTheme.accentColor

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        final message = authProvider.authMessage;
        final isAuthenticated = authProvider.isAuthenticated;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message ?? 'وضعیت نامشخص'),
            backgroundColor:
                isAuthenticated ? Colors.green : AppTheme.errorColor,
          ),
        );

        authProvider.clearMessage(); // پاک کردن پیام پس از نمایش

        if (isAuthenticated) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(Routes.home, (route) => false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ثبت نام کاربر جدید'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // لوگو یا تصویر (اختیاری)
                // Image.asset(AppAssets.logo, height: 100), //
                // const SizedBox(height: 30),
                const Text(
                  'ایجاد حساب کاربری',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                CustomTextField(
                  controller: _emailController,
                  labelText: 'ایمیل',
                  hintText: 'ایمیل خود را وارد کنید',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفا ایمیل خود را وارد کنید';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'لطفا یک ایمیل معتبر وارد کنید';
                    }
                    return null;
                  },
                  prefixIcon: Icons.email_outlined,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'رمز عبور',
                  hintText: 'رمز عبور خود را وارد کنید',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفا رمز عبور خود را وارد کنید';
                    }
                    if (value.length < 6) {
                      // بک‌اند حداقل ۶ کاراکتر می‌خواهد
                      return 'رمز عبور باید حداقل ۶ کاراکتر باشد';
                    }
                    return null;
                  },
                  prefixIcon: Icons.lock_outline,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _confirmPasswordController,
                  labelText: 'تکرار رمز عبور',
                  hintText: 'رمز عبور خود را مجددا وارد کنید',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفا تکرار رمز عبور را وارد کنید';
                    }
                    if (value != _passwordController.text) {
                      return 'رمزهای عبور مطابقت ندارند';
                    }
                    return null;
                  },
                  prefixIcon: Icons.lock_reset_outlined,
                ),
                const SizedBox(height: 30),
                authProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(text: 'ثبت نام', onPressed: _submitForm),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('قبلاً ثبت نام کرده‌اید؟'),
                    TextButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pushReplacementNamed(Routes.login);
                      },
                      child: Text(
                        'وارد شوید',
                        style: TextStyle(
                          color: AppTheme.accentColor,
                        ), // استفاده از رنگ تاکیدی
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
