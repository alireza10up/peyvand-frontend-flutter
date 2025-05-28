import 'package:flutter/material.dart';
import 'package:peyvand/config/app_assets.dart'; //
import 'package:peyvand/config/app_theme.dart'; //
import 'package:peyvand/config/routes.dart'; //
import 'package:peyvand/ui/widgets/common/custom_button.dart'; //
import 'package:peyvand/ui/widgets/common/custom_text_field.dart'; //
import 'package:peyvand/core/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  //
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //
  final _formKey = GlobalKey<FormState>(); //
  final _emailController = TextEditingController(); //
  final _passwordController = TextEditingController(); //
  // bool _isLoading = false; // وضعیت لودینگ توسط AuthProvider مدیریت می‌شود

  @override
  void dispose() {
    //
    _emailController.dispose(); //
    _passwordController.dispose(); //
    super.dispose(); //
  }

  Future<void> _loginUser(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) {
        // بررسی اینکه ویجت هنوز در درخت ویجت‌ها وجود دارد
        if (authProvider.isAuthenticated) {
          Navigator.pushReplacementNamed(context, Routes.home);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.authMessage ?? 'خطا در ورود'),
              backgroundColor: Colors.red,
            ),
          );
          authProvider.clearMessage(); // پاک کردن پیام پس از نمایش
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //
    // دریافت AuthProvider برای استفاده در UI (مثلاً برای نمایش دکمه لودینگ)
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      //
      body: SafeArea(
        //
        child: SingleChildScrollView(
          //
          padding: EdgeInsets.all(24), //
          child: Form(
            //
            key: _formKey, //
            child: Column(
              //
              crossAxisAlignment: CrossAxisAlignment.center, //
              children: [
                SizedBox(height: 40),
                //
                Container(
                  //
                  width: 100, //
                  height: 100, //
                  decoration: BoxDecoration(
                    //
                    color: AppTheme.primaryColor, //
                    shape: BoxShape.circle, //
                  ),
                  child: AppAssets.logoLarge(logoColor: Colors.white), //
                ),
                SizedBox(height: 24),
                //
                Text(
                  //
                  'پیوند', //
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    //
                    color: AppTheme.primaryColor, //
                    fontWeight: FontWeight.bold, //
                  ),
                ),
                SizedBox(height: 8),
                //
                Text(
                  //
                  'ارتباط، اشتراک‌گذاری و رشد با هوش مصنوعی', //
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    //
                    color: AppTheme.secondaryTextColor, //
                  ),
                ),
                SizedBox(height: 40),
                //
                CustomTextField(
                  //
                  label: 'ایمیل',
                  //
                  hintText: 'ایمیل خود را وارد کنید',
                  //
                  controller: _emailController,
                  //
                  keyboardType: TextInputType.emailAddress,
                  //
                  prefixIcon: Icons.email_outlined,
                  //
                  validator: (value) {
                    //
                    if (value == null || value.isEmpty) {
                      //
                      return 'لطفا ایمیل خود را وارد کنید'; //
                    }
                    if (!value.contains('@')) {
                      //
                      return 'لطفا یک ایمیل معتبر وارد کنید'; //
                    }
                    return null;
                  }, labelText: '', obscureText: null,
                ),
                SizedBox(height: 20),
                //
                CustomTextField(
                  //
                  label: 'رمز عبور',
                  //
                  hintText: 'رمز عبور خود را وارد کنید',
                  //
                  controller: _passwordController,
                  //
                  isPassword: true,
                  //
                  prefixIcon: Icons.lock_outline,
                  //
                  validator: (value) {
                    //
                    if (value == null || value.isEmpty) {
                      //
                      return 'لطفا رمز عبور خود را وارد کنید'; //
                    }
                    if (value.length < 6) {
                      //
                      return 'رمز عبور باید حداقل ۶ کاراکتر باشد'; //
                    }
                    return null;
                  }, labelText: '', obscureText: true,
                ),
                SizedBox(height: 16),
                //
                Align(
                  //
                  alignment: Alignment.centerRight, //
                  child: GestureDetector(
                    //
                    onTap: () {
                      //
                      Navigator.pushNamed(context, Routes.forgotPassword); //
                    },
                    child: Text(
                      //
                      'رمز عبور را فراموش کرده‌اید؟', //
                      style: TextStyle(
                        //
                        color: AppTheme.primaryColor, //
                        fontWeight: FontWeight.w500, //
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                //
                CustomButton(
                  //
                  text: 'ورود',
                  //
                  isLoading: authProvider.isLoading,
                  // استفاده از وضعیت لودینگ AuthProvider
                  onPressed: () => _loginUser(context), //
                ),
                SizedBox(height: 16),
                //
                Row(
                  //
                  mainAxisAlignment: MainAxisAlignment.center, //
                  children: [
                    Text("حساب کاربری ندارید؟"), //
                    SizedBox(width: 4), //
                    GestureDetector(
                      //
                      onTap: () {
                        //
                        Navigator.pushNamed(context, Routes.register); //
                      },
                      child: Text(
                        //
                        'ثبت نام', //
                        style: TextStyle(
                          //
                          color: AppTheme.primaryColor, //
                          fontWeight: FontWeight.bold, //
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                //
                // Social login (فعلا غیر فعال یا برای فاز بعد)
                // Text(
                //   'یا ورود با',
                //   style: TextStyle(color: AppTheme.secondaryTextColor),
                // ),
                // SizedBox(height: 16),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     _socialLoginButton(
                //       icon: Icons.g_mobiledata, // آیکون گوگل را با پکیج font_awesome_flutter یا مشابه می‌توان اضافه کرد
                //       onPressed: () {},
                //     ),
                //     // ... سایر دکمه‌های ورود با شبکه‌های اجتماعی
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //  Widget _socialLoginButton({required IconData icon, required VoidCallback onPressed}) {
  //    return InkWell(
  //      onTap: onPressed,
  //      child: Container(
  //        width: 60,
  //        height: 60,
  //        decoration: BoxDecoration(
  //          border: Border.all(color: Colors.grey.shade300),
  //          borderRadius: BorderRadius.circular(12),
  //        ),
  //        child: Icon(
  //          icon,
  //          size: 30,
  //          color: AppTheme.primaryTextColor,
  //        ),
  //      ),
  //    );
  //  }
}
