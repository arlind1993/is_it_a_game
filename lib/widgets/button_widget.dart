import 'package:flutter/material.dart';
import 'package:game_template/services/app_styles/app_color.dart';
import 'text_widget.dart';
import '../services/get_it_helper.dart';

class ButtonWidget extends StatelessWidget {
  final Key? key;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextWidget? textWidget;
  final double? elevation;
  final Color? elevationColor;
  final VoidCallback? action;
  final double? minWidth;
  final double? contentHeight;
  final Color? borderColor;
  final double? borderWidth;
  final double? borderRadius;
  final Color? backgroundColor;
  final double? paddingSpacing;
  final FocusNode focusNode;

  factory ButtonWidget({
    Key? key,
    double? minWidth,
    double? iconSize,
    Widget? prefixWidgetIcon,
    Widget? suffixWidgetIcon,
    IconData? prefixIcon,
    IconData? suffixIcon,
    Color? prefixColor,
    Color? suffixColor,
    TextWidget? textWidget,
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    double? borderRadius,
    double? elevation,
    Color? elevationColor,
    VoidCallback? action,
    double? contentHeight,
    double? paddingSpacing,
  }){
    iconSize ??= DefaultTextSizes.medium.value;
    prefixColor ??= getIt<AppColor>().ink;
    suffixColor ??= getIt<AppColor>().ink;
    elevationColor ??= getIt<AppColor>().ink;
    borderWidth ??= 1;
    prefixWidgetIcon ??= prefixIcon == null ? null : Icon(
      prefixIcon,
      color: prefixColor,
      size: iconSize,
    );
    suffixWidgetIcon ??= suffixIcon == null ? null : Icon(
      suffixIcon,
      color: suffixColor,
      size: iconSize,
    );
    return ButtonWidget._(
      key,
      minWidth,
      prefixWidgetIcon,
      suffixWidgetIcon,
      textWidget,
      action,
      elevation,
      elevationColor,
      contentHeight,
      backgroundColor,
      borderColor,
      borderWidth,
      borderRadius,
      paddingSpacing,
    );
  }

  ButtonWidget._(
    this.key,
    this.minWidth,
    this.prefixIcon,
    this.suffixIcon,
    this.textWidget,
    this.action,
    this.elevation,
    this.elevationColor,
    this.contentHeight,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.paddingSpacing,
  ):focusNode = FocusNode(), super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderOnForeground: true,
      shadowColor: elevationColor,

      elevation: elevation ?? 0,
      type: MaterialType.button,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius == null ? BorderRadius.zero : BorderRadius.circular(borderRadius!),
        side: borderColor == null || borderWidth == null ? BorderSide.none : BorderSide(
          color: borderColor!,
          width: borderWidth!,
        ),
      ),
      child: InkWell(
        onTap: () {
          if(action!=null) {
            action!();
          }
        },
        child: Container(
          clipBehavior: Clip.antiAlias,
          padding: paddingSpacing == null ? null : EdgeInsets.all(paddingSpacing!),
          constraints: BoxConstraints(
            minWidth: minWidth ?? 0,
          ),
          decoration: BoxDecoration(
            boxShadow: elevation == null ? null : [
              BoxShadow(
                  blurRadius: elevation!,
                  offset: Offset(0, -50),
                  color: Colors.grey,
                  spreadRadius: elevation!,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (prefixIcon != null) prefixIcon!,
              if(textWidget != null)
                Padding(
                  padding: EdgeInsets.only(
                    left: prefixIcon == null ? 0 : paddingSpacing ?? 0,
                    right: suffixIcon == null ? 0 : paddingSpacing ?? 0,
                  ),
                  child: textWidget!
                ),
              if (suffixIcon != null) suffixIcon!,
            ],
          ),
        ),
      ),
    );
  }
}