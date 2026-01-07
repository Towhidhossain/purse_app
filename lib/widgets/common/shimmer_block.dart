import 'package:flutter/material.dart';

class ShimmerBlock extends StatelessWidget {
  const ShimmerBlock({
    super.key,
    required this.height,
    this.width,
    this.margin,
    this.borderRadius,
  });

  final double height;
  final double? width;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.9, end: 1.1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: 0.92,
          child: Container(
            height: height,
            width: width,
            margin: margin,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.surfaceVariant.withOpacity(0.28 * value),
                  colors.surfaceVariant.withOpacity(0.55 * value),
                ],
              ),
              borderRadius: borderRadius ?? BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
