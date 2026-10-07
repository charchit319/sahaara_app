import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const PageHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 30,
                decoration: BoxDecoration(
                    color: AppColors.maroon, borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: AppTheme.heading(28))),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: AppTheme.body(14, color: AppColors.tan)),
        ],
      ),
    );
  }
}
