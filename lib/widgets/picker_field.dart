import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Looks like AppTextField, but opens a picker when tapped.
class PickerField extends StatelessWidget {
  final IconData icon;
  final String label; // shown while nothing is picked
  final String? value;
  final VoidCallback onTap;

  const PickerField({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final has = value != null;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.55),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white.withOpacity(0.7)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.brown, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                has ? value! : label,
                style: AppTheme.body(15, color: has ? AppColors.text : AppColors.tan),
              ),
            ),
            const Icon(Icons.expand_more_rounded, color: AppColors.tan, size: 20),
          ],
        ),
      ),
    );
  }
}