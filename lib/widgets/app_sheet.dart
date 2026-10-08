import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Rounded cream bottom sheet used for all "add / invite / view" forms.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required String title,
  required Widget child,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                        color: AppColors.tan.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(5)),
                  ),
                ),
                const SizedBox(height: 18),
                Text(title, style: AppTheme.heading(22)),
                const SizedBox(height: 16),
                child,
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
