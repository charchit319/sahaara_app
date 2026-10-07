import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Rounded pill button — filled (primary) or outlined (secondary).
class PillButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool outlined;
  final IconData? icon;

  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.outlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final fg = outlined ? AppColors.maroon : AppColors.sand;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          gradient: outlined
              ? null
              : const LinearGradient(colors: [AppColors.maroon, AppColors.maroonDark]),
          border: outlined ? Border.all(color: AppColors.maroon, width: 1.2) : null,
          boxShadow: outlined
              ? null
              : [
                  BoxShadow(
                    color: AppColors.maroon.withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(40),
            onTap: onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[Icon(icon, color: fg, size: 20), const SizedBox(width: 8)],
                Text(label,
                    style: AppTheme.body(16, color: fg, weight: FontWeight.w600)
                        .copyWith(letterSpacing: 0.6)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
