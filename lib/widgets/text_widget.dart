import 'package:flutter/material.dart';
import 'package:game_template/services/app_styles/app_color.dart';
import 'package:game_template/services/get_it_helper.dart';

enum DefaultTextSizes{
  little,
  small,
  medium,
  large,
  extra,
  enormous,
  custom,
}
enum DefaultTextFamily{
  roboto,
  permanentMarker,
  custom,
}

enum DefaultTextWeight{
  hair,
  thin,
  regular,
  bold,
  thick,
  custom,
}

class TextWidget extends StatelessWidget {
  final String text;
  final Key? key;
  final TextAlign textAlign;
  late final double textSize;
  late final String textFamily;
  late final FontWeight textWeight;
  late final Color textColor;

  TextWidget({
    required this.text,
    this.key,
    this.textAlign = TextAlign.center,
    DefaultTextSizes? defaultTextSizes,
    double? customTextSize,
    DefaultTextFamily? defaultTextFamily,
    String? customTextFamily,
    DefaultTextWeight? defaultTextWeight,
    FontWeight? customTextWeight,
    Color? textColor,
  }) : super(key: key) {
    switch(defaultTextSizes){
      case DefaultTextSizes.little: textSize = 9; break;
      case DefaultTextSizes.small: textSize = 12; break;
      case DefaultTextSizes.medium: textSize = 16; break;
      case DefaultTextSizes.large: textSize = 18; break;
      case DefaultTextSizes.extra: textSize = 24; break;
      case DefaultTextSizes.enormous: textSize = 32; break;
      case DefaultTextSizes.custom: default: textSize = customTextSize ?? 16; break;
    }
    switch(defaultTextFamily){
      case DefaultTextFamily.roboto: textFamily = "Roboto"; break;
      case DefaultTextFamily.permanentMarker: textFamily = "PermanentMarker"; break;
      case DefaultTextFamily.custom: default: textFamily = customTextFamily ?? ""; break;
    }

    switch(defaultTextWeight){
      case DefaultTextWeight.hair: textWeight = FontWeight.w100; break;
      case DefaultTextWeight.thin: textWeight = FontWeight.w300; break;
      case DefaultTextWeight.regular: textWeight = FontWeight.w500; break;
      case DefaultTextWeight.bold: textWeight = FontWeight.w700; break;
      case DefaultTextWeight.thick: textWeight = FontWeight.w900; break;
      case DefaultTextWeight.custom: default: textWeight = customTextWeight ?? FontWeight.w500; break;
    }

    this.textColor = textColor ?? getIt<AppColor>().ink;
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      key: key,
      textAlign: textAlign,
      style: TextStyle(
        fontFamily: textFamily,
        fontSize: textSize,
        fontWeight: textWeight,
        color: textColor,
      ),
    );
  }
}
