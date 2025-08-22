import 'dart:ui';
import 'package:flutter/material.dart';

class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double blur;
  final List<Color> gradientColors;
  final double borderWidth;
  final Color borderColor;
  final BoxShadow? boxShadow;

  const GlassmorphicContainer({
    Key? key,
    required this.child,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(20),
    this.margin = const EdgeInsets.symmetric(horizontal: 24),
    this.blur = 12.0,
    this.gradientColors = const [
      Colors.white24,
      Colors.white10,
    ],
    this.borderWidth = 1.0,
    this.borderColor = Colors.white24,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final shadow = boxShadow ??
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 16,
          offset: const Offset(0, 6),
        );

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: borderColor, width: borderWidth),
              boxShadow: [shadow],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
