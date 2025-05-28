import 'package:flutter/material.dart';
import 'package:peyvand/config/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final int maxLines;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? initialValue;

  const CustomTextField({
    super.key,
    this.label,
    this.hintText,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffix,
    this.readOnly = false,
    this.onTap,
    this.initialValue, required String labelText, required bool obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          validator: validator,
          obscureText: isPassword,
          keyboardType: keyboardType,
          maxLines: isPassword ? 1 : maxLines,
          onChanged: onChanged,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffix: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}