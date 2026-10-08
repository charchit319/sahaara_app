import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'pill_button.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool dark; // cool "lightbox" style for X-rays & scans
  final IconData actionIcon;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.dark = false,
    this.actionIcon = Icons.add_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dark ? AppColors.scanDark : AppColors.maroon.withOpacity(0.08),
                border: Border.all(
                  color: dark
                      ? AppColors.scanAccent.withOpacity(0.35)
                      : AppColors.maroon.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              child: Icon(icon,
                  size: 42,
                  color: dark ? AppColors.scanAccent : AppColors.maroon.withOpacity(0.7)),
            ),
            const SizedBox(height: 20),
            Text(title, textAlign: TextAlign.center, style: AppTheme.heading(20)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: AppTheme.body(14, color: AppColors.tan)),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 22),
              SizedBox(
                width: 240,
                child: PillButton(
                  label: actionLabel!,
                  icon: actionIcon,
                  onPressed: onAction!,
                  color: dark ? AppColors.scanDark : null,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}