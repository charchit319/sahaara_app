import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Your website logo. Falls back to an icon if the asset is missing.
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/app_logo_no_bg.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) =>
          Icon(Icons.volunteer_activism_rounded, size: size * 0.7, color: AppColors.maroon),
    );
  }
}
