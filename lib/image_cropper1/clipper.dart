import 'dart:ui' as ui;
import 'package:flutter/material.dart';

enum ClipShape {
  rect,
  rrect,
  circle,
  heart,
}

class InvertedClipper extends CustomClipper<Path> {
  InvertedClipper({
    required this.clipSize,
    required this.shape,
    this.rrectRadius,
  });

  final Size clipSize;
  final ClipShape shape;
  final Radius? rrectRadius;

  @override
  Path getClip(Size size) {
    var pathRect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: clipSize.width,
      height: clipSize.height,
    );

    Path path = Path();
    if (shape == ClipShape.circle) {
      path.addOval(pathRect);
    } else if (shape == ClipShape.rrect) {
      path.addRRect(
        ui.RRect.fromRectAndRadius(
          pathRect,
          rrectRadius ?? const Radius.circular(10),
        ),
      );
    } else if (shape == ClipShape.rect) {
      path.addRect(pathRect);
    }

     path.close();
    return Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      path,
    );
  }

  @override
  bool shouldReclip(InvertedClipper oldClipper) {
    return clipSize != oldClipper.clipSize ||
        shape != oldClipper.shape ||
        rrectRadius != oldClipper.rrectRadius;
  }
}
