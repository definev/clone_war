import 'package:flutter/material.dart';

const double curveWidth = 110;

class ForegroundBubblePainter extends CustomPainter {
  const ForegroundBubblePainter(
    this.progress,
    this.backgroundColor,
  );

  final double progress;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 0.4) return;
    if (size.height <= 0) return;
    _upperPainter(canvas, size);

    // if (progress <= 0.5) {
    //   _upperPainter(canvas, size);
    // } else {
    //   _downPainter(canvas, size);
    // }
  }

  @override
  bool shouldRepaint(covariant ForegroundBubblePainter oldDelegate) => false;

  void _upperPainter(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final curvePath = Path();

    final wide = size.height < 100 ? size.height / 2 : curveWidth / 2;

    curvePath
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2 - curveWidth, size.height)
      ..cubicTo(
        size.width / 2,
        size.height + 15,
        size.width / 2 - wide,
        0,
        size.width / 2,
        0,
      )
      ..cubicTo(
        size.width / 2 + wide,
        0,
        size.width / 2,
        size.height + 15,
        size.width / 2 + curveWidth,
        size.height,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(size.width - curveWidth, size.height + 1)
      ..lineTo(curveWidth, size.height + 1);

    canvas.drawPath(curvePath, paint);
  }
}

class BouncingBubblePainter extends CustomPainter {
  const BouncingBubblePainter(
    this.progress,
    this.backgroundColor,
  );

  final double progress;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress * size.height < 0) {
      final paint = Paint()..color = backgroundColor;
      canvas.drawRect(
        Rect.fromLTWH(
          size.width / 2 - curveWidth,
          -100,
          curveWidth * 2,
          size.height,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BouncingBubbleClip extends CustomClipper<Path> {
  const BouncingBubbleClip(this.progress);

  final double progress;

  @override
  Path getClip(Size size) {
    final wide = progress * size.height < 100
        ? progress * size.height * 1.2
        : curveWidth / 2;

    final notchPath = Path()
      ..lineTo(0, 0)
      ..lineTo(size.width / 2 - curveWidth, 0)
      ..cubicTo(
        size.width / 2,
        0,
        size.width / 2 - wide,
        progress * size.height,
        size.width / 2,
        progress * size.height,
      )
      ..cubicTo(
        size.width / 2 + wide,
        progress * size.height,
        size.width / 2,
        0,
        size.width / 2 + curveWidth,
        0,
      )
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height);

    return notchPath;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
