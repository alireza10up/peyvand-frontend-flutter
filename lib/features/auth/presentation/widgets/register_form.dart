import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peyvand/features/auth/data/providers/auth_provider.dart';
import 'package:peyvand/features/main/presentation/screens/main_tab_screen.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.register(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      if (authProvider.authMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.authMessage!),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(10),
          ),
        );
      }

      authProvider.clearMessage();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainTabScreen()),
            (Route<dynamic> route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.authMessage ?? 'خطا در ثبت نام. لطفاً دوباره تلاش کنید.'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(10),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _emailController,
                  enabled: !authProvider.isActionLoading,
                  decoration: const InputDecoration(
                    labelText: 'پست الکترونیکی',
                    hintText: 'example@example.com',
                    prefixIcon: Icon(Icons.alternate_email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفا ایمیل خود را وارد کنید';
                    }
                    final emailRegex = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                    if (!emailRegex.hasMatch(value)) {
                      return 'لطفا یک ایمیل معتبر وارد کنید';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _passwordController,
                  enabled: !authProvider.isActionLoading,
                  decoration: InputDecoration(
                    labelText: 'رمز عبور',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: authProvider.isActionLoading ? null : () {
                        setState(() { _obscurePassword = !_obscurePassword; });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفا رمز عبور خود را وارد کنید';
                    }
                    if (value.length < 6) {
                      return 'رمز عبور باید حداقل ۶ کاراکتر باشد';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _confirmPasswordController,
                  enabled: !authProvider.isActionLoading,
                  decoration: InputDecoration(
                    labelText: 'تکرار رمز عبور',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: authProvider.isActionLoading ? null : () {
                        setState(() { _obscureConfirmPassword = !_obscureConfirmPassword; });
                      },
                    ),
                  ),
                  obscureText: _obscureConfirmPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفا تکرار رمز عبور خود را وارد کنید';
                    }
                    if (value != _passwordController.text) {
                      return 'رمزهای عبور با یکدیگر تطابق ندارند';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                authProvider.isActionLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _register,
                  child: const Text('ایجاد حساب کاربری'),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("قبلاً ثبت نام کرده‌اید؟ ", style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                    TextButton(
                      onPressed: authProvider.isActionLoading ? null : () {
                        DefaultTabController.of(context)?.animateTo(0);
                      },
                      child: Text(
                        "وارد شوید",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}