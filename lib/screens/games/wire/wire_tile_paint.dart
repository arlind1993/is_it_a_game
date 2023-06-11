import 'dart:ui';

import 'package:flutter/material.dart';

class WireTilePaint extends CustomPainter{
  List<Offset> centers;
  List<List<Offset>> points;
  WireTilePaint(this.centers, this.points);
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = Colors.cyan;
    for(int i = 0; i<size.width; i+=20){
      canvas.drawLine(Offset(i.toDouble(), 0), Offset(i.toDouble(), size.height), paint);
    }

    for(int i = 0; i<size.height; i+=20){
      canvas.drawLine(Offset(0,i.toDouble()), Offset(size.width, i.toDouble()), paint);
    }
    paint.color = Colors.black;
    paint.strokeWidth = 5;
    canvas.drawPoints(PointMode.points, centers, paint);

    paint.color = Colors.red;
    paint.strokeWidth = 2;
    for(List<Offset> sp in points){
      canvas.drawPath(Path()..addPolygon(sp, true), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

}