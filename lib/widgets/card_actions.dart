import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Visible Edit / Delete buttons shown at the bottom of a card.
class CardActions extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const CardActions({super.key, required this.onEdit, required this.onDelete});

  Widget _btn(IconData icon, String label, Color color, VoidCallback onTap) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, style: AppTheme.body(13, color: color, weight: FontWeight.w700)),
      style: TextButton.styleFrom(
        foregroundColor: color,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        minimumSize: const Size(0, 36),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _btn(Icons.edit_rounded, 'Edit', AppColors.maroon, onEdit),
        const SizedBox(width: 6),
        _btn(Icons.delete_outline_rounded, 'Delete', Colors.red.shade700, onDelete),
      ],
    );
  }
}

/// Asks "Delete this …?" and returns true only if the user confirms.
Future<bool> confirmDelete(BuildContext context, String what) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.cream,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Text('Delete $what?', style: AppTheme.heading(20)),
      content: Text('This cannot be undone.', style: AppTheme.body(14, color: AppColors.tan)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text('Cancel',
              style: AppTheme.body(14, color: AppColors.brown, weight: FontWeight.w600)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text('Delete',
              style: AppTheme.body(14, color: Colors.red.shade700, weight: FontWeight.w700)),
        ),
      ],
    ),
  );
  return ok ?? false;
}