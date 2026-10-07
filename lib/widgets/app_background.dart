import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Warm cream gradient with soft "glow" circles behind content.
class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF3EADA), AppColors.cream, AppColors.sand],
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -90, left: -80, child: _blob(260, AppColors.maroon.withOpacity(0.10))),
          Positioned(bottom: -110, right: -90, child: _blob(300, AppColors.tan.withOpacity(0.25))),
          child,
        ],
      ),
    );
  }

  Widget _blob(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}
