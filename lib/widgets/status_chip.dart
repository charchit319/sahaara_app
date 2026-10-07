import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatusChip extends StatelessWidget {
  final bool upcoming;
  const StatusChip({super.key, required this.upcoming});

  @override
  Widget build(BuildContext context) {
    final color = upcoming ? AppColors.success : AppColors.muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        upcoming ? 'UPCOMING' : 'PAST',
        style: AppTheme.body(10, color: color, weight: FontWeight.w800)
            .copyWith(letterSpacing: 1),
      ),
    );
  }
}
