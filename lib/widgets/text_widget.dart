import 'dart:math';

import 'package:flutter/material.dart';
import 'package:game_template/services/app_styles/app_color.dart';
import 'package:game_template/services/get_it_helper.dart';

enum DefaultTextSizes {
  little,
  small,
  medium,
  large,
  extra,
  enormous,
} extension ExtensionTextSizes on DefaultTextSizes{
  double get value {
    switch(this){
      case DefaultTextSizes.little: return 9;
      case DefaultTextSizes.small: return 12;
      case DefaultTextSizes.medium: return 16;
      case DefaultTextSizes.large: return 18;
      case DefaultTextSizes.extra: return 24;
      case DefaultTextSizes.enormous: return 32;
    }
  }
}

enum DefaultTextFamily{
  roboto,
  permanentMarker,
  magneto,
} extension ExtensionTextFamily on DefaultTextFamily{
  String get value {
    switch(this){
      case DefaultTextFamily.roboto: return "Roboto";
      case DefaultTextFamily.permanentMarker: return "Permanent Marker";
      case DefaultTextFamily.magneto: return "Magneto";
    }
  }
}

enum DefaultTextWeight{
  hair,
  thin,
  regular,
  bold,
  thick,
} extension ExtensionTextWeight on DefaultTextWeight{
  FontWeight get value {
    switch(this){
      case DefaultTextWeight.hair: return FontWeight.w100;
      case DefaultTextWeight.thin: return FontWeight.w300;
      case DefaultTextWeight.regular: return FontWeight.w400;
      case DefaultTextWeight.bold: return FontWeight.w700;
      case DefaultTextWeight.thick: return FontWeight.w900;
    }
  }
}

class TextWidget extends StatelessWidget {
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
    textColor ??= getIt<AppColor>().ink;
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
