import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// The Dhaka ribbon pattern from the website.
/// vertical: true  -> as-is (side strip)
/// vertical: false -> rotated, for horizontal bands.
class Ribbon extends StatelessWidget {
  final bool vertical;
  const Ribbon({super.key, this.vertical = true});

  @override
  Widget build(BuildContext context) {
    final img = Image.asset(
      'assets/images/dhaka.png',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: AppColors.maroon),
    );
    return vertical ? img : RotatedBox(quarterTurns: 1, child: img);
  }
}
