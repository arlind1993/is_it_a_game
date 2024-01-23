import 'dart:math';

import 'package:flutter/material.dart';
import 'package:game_template/services/app_styles/app_color.dart';
import 'package:game_template/services/get_it_helper.dart';

enum DefaultTextSizes {
  little(9),
  small(12),
  medium(16),
  large(18),
  extra(24),
  enormous(32);
  const DefaultTextSizes(this.value);
  final double value;
}

enum DefaultTextFamily{
  roboto("Roboto"),
  permanentMarker("Permanent Marker"),
  magneto("Magneto");
  const DefaultTextFamily(this.value);
  final String value;
}

enum DefaultTextWeight{
  hair(FontWeight.w100),
  thin(FontWeight.w300),
  regular(FontWeight.w400),
  bold(FontWeight.w700),
  thick(FontWeight.w900);
  const DefaultTextWeight(this.value);
  final FontWeight value;
}


class TextWidget extends StatelessWidget {
  static final Color defaultColor = global.color.ink;
  final String text;
  final Key? key;
  final TextDirection? textDirection;
  final TextAlign? textAlign;
  final FontWeight? textWeight;
  final double? lineHeight;
  final double? textSize;
  final Color? textColor;
  final String? textFamily;
  final int? maxLines;
  final TextOverflow? overflowType;
  final List<Shadow>? shadows;

  factory TextWidget.fromStyle({
    required String text,
    Key? key,
    TextAlign textAlign = TextAlign.center,
    int? maxLines,
    TextOverflow? overflowType,
    double? strokeWidth,
    Color? strokeColor,
    TextDirection? textDirection,
    TextStyle? textStyle
  }){
    return TextWidget(
        text: text,
        key: key,
        textAlign: textAlign,
        textColor: textStyle?.color,
        lineHeight: textStyle?.height,
        textSize: textStyle?.fontSize,
        textFamily: textStyle?.fontFamily,
        textWeight: textStyle?.fontWeight,
        shadows: textStyle?.shadows,
        maxLines: maxLines,
        overflowType: overflowType,
        strokeWidth: strokeWidth,
        strokeColor: strokeColor,
        textDirection: textDirection,
    );
  }

  factory TextWidget({
    required String text,
    Key? key,
    TextAlign textAlign = TextAlign.center,
    Color? textColor,
    double? lineHeight,
    double? textSize,
    String? textFamily,
    FontWeight? textWeight,
    int? maxLines,
    TextOverflow? overflowType,
    List<Shadow>? shadows,
    double? strokeWidth,
    Color? strokeColor,
    TextDirection? textDirection,
  }){
    textColor ??= defaultColor;
    final paint = Paint();
    paint.color = textColor;
    paint.style = PaintingStyle.fill;
    int precision = 20;
    if(strokeWidth != null && strokeColor!=null){
      shadows = List.generate(precision, (index) {
        final indexRadAngle = 2 * pi / precision * index;
        return Shadow(
          color: strokeColor,
          offset: Offset(cos(indexRadAngle)* strokeWidth, sin(indexRadAngle)* strokeWidth)
        );
      });
    }
    return TextWidget._(
      text,
      key,
      textAlign,
      textWeight,
      lineHeight,
      textSize,
      textColor,
      textFamily,
      maxLines,
      overflowType,
      shadows,
      textDirection,
    );
  }

  TextWidget._(
    this.text,
    this.key,
    this.textAlign,
    this.textWeight,
    this.lineHeight,
    this.textSize,
    this.textColor,
    this.textFamily,
    this.maxLines,
    this.overflowType,
    this.shadows,
    this.textDirection,
  ) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      key: key,
      textDirection: textDirection,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflowType,
      style: TextStyle(
        height: lineHeight,
        fontFamily: textFamily,
        fontSize: textSize,
        fontWeight: textWeight,
        shadows: shadows,
        color: textColor
      )
    );
  }
}
