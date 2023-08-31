import 'package:flutter/material.dart';
import 'dart:math';

class TouchIndicatorPainter extends CustomPainter {
  final Offset touchPosition;

  TouchIndicatorPainter(this.touchPosition);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint outerCirclePaint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final Paint innerCirclePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final double radius = size.width * 0.4; // Adjust the size of the joystick outer circle

    final Offset center = Offset(size.width / 2, size.height / 2);

    // Calculate the displacement of the joystick handle from the center
    final double deltaX = touchPosition.dx - center.dx;
    final double deltaY = touchPosition.dy - center.dy;

    // Calculate the distance from the center to the touch position
    final double distance = sqrt(deltaX * deltaX + deltaY * deltaY);

    // Ensure that the joystick handle stays within the bounds of the base circle
    if (distance > radius) {
      print("in if");
      print(touchPosition);
      final double angle = atan2(deltaY, deltaX);
      final double clampedX = cos(angle) * radius;
      final double clampedY = sin(angle) * radius;
      final Offset clampedPosition = center + Offset(clampedX, clampedY);
      canvas.drawCircle(clampedPosition, radius * 0.3, innerCirclePaint);
    } else {
      print("in else");
      // Draw the inner circle (joystick handle) at the touch position
      canvas.drawCircle(touchPosition, radius * 0.3, innerCirclePaint);
    }

    // Draw the outer circle (joystick base)
    canvas.drawCircle(center, radius, outerCirclePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
