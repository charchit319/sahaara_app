import 'dart:ui';
import 'package:flutter/material.dart';

/// Frosted-glass card, same look as the website's appointment cards.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.radius = 32,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF60181E).withOpacity(0.10),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Material(
            color: Colors.white.withOpacity(0.38),
            child: InkWell(
              onTap: onTap,
              child: Container(
                padding: padding,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.6)),
                  borderRadius: BorderRadius.circular(radius),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
