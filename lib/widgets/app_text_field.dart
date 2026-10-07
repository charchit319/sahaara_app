import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isPassword;
  final int maxLines;
  final TextInputType? keyboardType;

  const AppTextField({
    super.key,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _hidden = true;

  OutlineInputBorder _border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.maxLines > 1 ? 24 : 40),
        borderSide: BorderSide(color: c, width: w),
      );

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: widget.isPassword && _hidden,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      keyboardType: widget.keyboardType,
      cursorColor: AppColors.maroon,
      style: AppTheme.body(15),
      decoration: InputDecoration(
        hintText: widget.label,
        hintStyle: AppTheme.body(15, color: AppColors.tan),
        prefixIcon: Icon(widget.icon, color: AppColors.brown, size: 20),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(_hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.tan, size: 20),
                onPressed: () => setState(() => _hidden = !_hidden),
              )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.55),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: _border(Colors.white.withOpacity(0.7)),
        enabledBorder: _border(Colors.white.withOpacity(0.7)),
        focusedBorder: _border(AppColors.maroon, 1.4),
      ),
    );
  }
}
