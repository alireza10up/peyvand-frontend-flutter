import 'package:flutter/material.dart';
import 'package:peyvand/config/app_theme.dart';

class AiEnhanceButton extends StatelessWidget {
  final VoidCallback onTap;

  const AiEnhanceButton({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              Icons.auto_fix_high,
              size: 16,
              color: AppTheme.primaryColor,
            ),
            SizedBox(width: 4),
            Text(
              'بهبود هوش مصنوعی',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}