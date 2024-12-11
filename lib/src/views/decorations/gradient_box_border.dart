import 'package:flutter/material.dart';
import 'dart:ui' show lerpDouble;

/// A custom [BoxBorder] that paints a gradient border around a box.
class GradientBoxBorder extends BoxBorder {
  final Gradient gradient;
  final double width;

  const GradientBoxBorder({
    required this.gradient,
    this.width = 1.0,
  });

  @override
  BorderSide get top => BorderSide(width: width);
  @override
  BorderSide get right => BorderSide(width: width);
  @override
  BorderSide get bottom => BorderSide(width: width);
  @override
  BorderSide get left => BorderSide(width: width);

  @override
  void paint(Canvas canvas, Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    final Paint paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;

    final RRect rrect = borderRadius?.toRRect(rect) ?? RRect.fromRectXY(rect, 0, 0);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool get isUniform => true;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  BoxBorder scale(double t) => GradientBoxBorder(
    gradient: gradient,
    width: width * t,
  );

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is GradientBoxBorder) {
      return GradientBoxBorder(
        gradient: gradient,
        width: lerpDouble(a.width, width, t)!,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is GradientBoxBorder) {
      return GradientBoxBorder(
        gradient: gradient,
        width: lerpDouble(width, b.width, t)!,
      );
    }
    return super.lerpTo(b, t);
  }
} 