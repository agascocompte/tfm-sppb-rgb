import 'package:flutter/material.dart';

class PolygonPainter extends CustomPainter {
  final List<Map<String, double>> points;
  final double offset;

  PolygonPainter({
    required this.points,
    this.offset = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 0, 255, 0)
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    final path = Path();
    if (points.isNotEmpty) {
      path.moveTo(-points[0]['y']! + offset, points[0]['x']!);
      for (var i = 1; i < points.length; i++) {
        path.lineTo(-points[i]['y']! + offset, points[i]['x']!);
      }
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
