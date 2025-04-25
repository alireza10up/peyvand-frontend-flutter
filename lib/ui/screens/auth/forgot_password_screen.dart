import 'package:flutter/material.dart';
import 'package:peyvand/config/app_theme.dart';
import 'package:peyvand/ui/widgets/common/custom_button.dart';
import 'package:peyvand/ui/widgets/common/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
          _emailSent = true;
        });
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
          child: _emailSent ? _buildSuccessView() : _buildRequestView(),
        ),
      ),
    );
  }

  Widget _buildRequestView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'بازیابی رمز عبور',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'ایمیل خود را وارد کنید و ما لینک بازیابی رمز عبور را برای شما ارسال خواهیم کرد.',
            style: TextStyle(
              color: AppTheme.lightTextColor,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 32),
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
          SizedBox(height: 24),
          // Reset button
          CustomButton(
            text: 'ارسال لینک بازیابی',
            isLoading: _isLoading,
            onPressed: _resetPassword,
          ),
          SizedBox(height: 16),
          // Back to login
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'بازگشت به صفحه ورود',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 40),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.email,
            size: 50,
            color: AppTheme.primaryColor,
          ),
        ),
        SizedBox(height: 32),
        Text(
          'ایمیل خود را بررسی کنید',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Text(
          'ما لینک بازیابی رمز عبور را به این آدرس ارسال کردیم:',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.secondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          _emailController.text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24),
        Text(
          'لطفا ایمیل خود را بررسی کنید و دستورالعمل‌های بازیابی رمز عبور را دنبال کنید.',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.lightTextColor,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 40),
        CustomButton(
          text: 'بازگشت به صفحه ورود',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        SizedBox(height: 16),
        TextButton(
          onPressed: () {
            setState(() {
              _emailSent = false;
            });
          },
          child: Text(
            'ایمیل را دریافت نکردید؟ دوباره تلاش کنید',
            style: TextStyle(
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}