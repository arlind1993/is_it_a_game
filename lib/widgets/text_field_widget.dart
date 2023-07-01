import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:game_template/widgets/text_widget.dart';

import '../services/app_styles/app_color.dart';
import '../services/extensions/easy_widget_extensions.dart';
import '../services/get_it_helper.dart';

enum TextFieldTypes{
  text,
  paragraph,
  email,
  password,
  number,
  integer,
  phone,
  address,
  date,
}extension TextFieldTypesExtension on TextFieldTypes{
  TextInputType inputType(){
    switch(this){
      case TextFieldTypes.text: return TextInputType.text;
      case TextFieldTypes.paragraph: return TextInputType.multiline;
      case TextFieldTypes.email: return TextInputType.emailAddress;
      case TextFieldTypes.password: return TextInputType.visiblePassword;
      case TextFieldTypes.number: return TextInputType.numberWithOptions(signed: true, decimal: true);
      case TextFieldTypes.integer: return TextInputType.numberWithOptions(signed: true);
      case TextFieldTypes.phone: return TextInputType.phone;
      case TextFieldTypes.address: return TextInputType.streetAddress;
      case TextFieldTypes.date: return TextInputType.datetime;
    }
  }
  Map<String, String> automaticValidationRegex(){
    switch(this){
      case TextFieldTypes.text: return {".*" : "The field is not a text"};
      case TextFieldTypes.paragraph: return {};
      case TextFieldTypes.email: return {"a":"email"};
      case TextFieldTypes.password: return {};
      case TextFieldTypes.number: return {};
      case TextFieldTypes.integer: return {};
      case TextFieldTypes.phone: return {};
      case TextFieldTypes.address: return {};
      case TextFieldTypes.date: return {};
    }
  }
  Map<String, String> validationRegex(){
    switch(this){
      case TextFieldTypes.text: return {".*" : "The field is not a text"};
      case TextFieldTypes.paragraph: return {};
      case TextFieldTypes.email: return {"al":"email sss"};
      case TextFieldTypes.password: return {};
      case TextFieldTypes.number: return {};
      case TextFieldTypes.integer: return {};
      case TextFieldTypes.phone: return {};
      case TextFieldTypes.address: return {};
      case TextFieldTypes.date: return {};
    }
  }
}

class TextFieldWidget extends StatelessWidget {
  final String unique;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double paddingHorizontal;
  final double paddingVertical;
  final double? marginHorizontal;
  final double? elevation;
  final Color? elevationColor;
  final Color backgroundColor;
  final TextEditingController editingController;
  final FocusNode focusNode;
  final FocusNodeController focusNodeController;
  final int? maxLines;
  final int? minLines;
  final String? initialValue;
  final String? placeholder;
  final String? label;
  final TextInputType? textInputType;
  final Map<String, String> autoValidateRegex;
  final Map<String, String> validateRegex;
  final TextInputAction? textInputAction;
  final bool required;
  final ValueNotifier<bool> submitted;
  final ValueNotifier<bool> obscured;
  final ValueNotifier<String> error;
  final InputBorder border;
  final InputBorder borderFocused;
  final TextStyle textStyle;
  final TextStyle labelStyle;
  final TextStyle hintStyle;
  final TextStyle errorStyle;

  factory TextFieldWidget({
    required FocusNodeController focusNodeController,
    double? iconSize,
    Widget? prefixWidgetIcon,
    Widget? suffixWidgetIcon,
    IconData? prefixIcon,
    IconData? suffixIcon,
    Color? prefixColor,
    Color? suffixColor,
    Color? iconColor,
    ///
    double paddingHorizontal = 10,
    double paddingVertical = 5,
    double? marginHorizontal,
    double? elevation,
    Color? elevationColor,
    ///
    String? placeholder,
    String? label,
    String? initialValue,
    TextInputAction? inputAction = TextInputAction.next,
    bool required = true,
    int? maxLines,
    int? minLines,
    Color? backgroundColor,
    ///
    TextFieldTypes? textFieldTypes = TextFieldTypes.text,
    TextInputType? textInputType,
    Map<String, String> autoValidateRegex = const{},
    Map<String, String> validateRegex = const{},
    ///
    bool underlineBorder = false,
    Color? borderColor,
    Color? borderFocusedColor,
    double? borderWidth,
    double? borderRadius,
    ///
    Color? textColor,
    double? textLineHeight,
    String? textFamily,
    double? textSize,
    FontWeight? textWeight,
    Color? errorTextColor,
    double? errorTextSize,
    FontWeight? errorTextWeight,
    Color? hintTextColor,
    double? hintTextSize,
    FontWeight? hintTextWeight,
    Color? labelTextColor,
    double? labelTextSize,
    FontWeight? labelTextWeight,
  }){

    Random r = Random();
    String all = 'AaBbCcDdlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1EeFfGgHhIiJjKkL234567890';
    String unique = List.generate(8, (index) => all[r.nextInt(all.length)]).join();

    backgroundColor ??= Colors.transparent;
    iconSize ??= DefaultTextSizes.medium.value;
    iconColor ??= getIt<AppColor>().ink;
    prefixColor ??= iconColor;
    suffixColor ??= iconColor;
    elevationColor ??= getIt<AppColor>().ink;
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
    ValueNotifier<bool> obscured = ValueNotifier(false);
    if(textFieldTypes != null){
      textInputType = textFieldTypes.inputType();
      autoValidateRegex = textFieldTypes.automaticValidationRegex();
      validateRegex = textFieldTypes.validationRegex();
      if(textFieldTypes == TextFieldTypes.password){
        minLines = null;
        maxLines = 1;
        suffixWidgetIcon = Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              obscured.value = !obscured.value;
            },
            child: ValueListenableBuilder(
              valueListenable: obscured,
              builder: (context, value, _) {
                return Icon(
                  value ? Icons.visibility_off : Icons.visibility,
                  color: suffixColor,
                  size: iconSize,
                );
              },
            ),
          ),
        );
      }
    }
    borderRadius??=10;
    borderColor??=getIt<AppColor>().ink;
    borderFocusedColor??=getIt<AppColor>().greenMain;
    borderWidth??= 2;
    InputBorder border = underlineBorder ? UnderlineInputBorder(
        borderSide: BorderSide(
          color: borderColor,
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ): OutlineInputBorder(
      borderSide: BorderSide(
        color: borderColor,
        width: borderWidth,
      ),
      gapPadding: borderRadius,
      borderRadius: BorderRadius.circular(borderRadius),
    );
    InputBorder borderFocused = underlineBorder ? UnderlineInputBorder(
      borderSide: BorderSide(
        color: borderColor,
        width: borderWidth,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
    ): OutlineInputBorder(
      borderSide: BorderSide(
        color: borderFocusedColor,
        width: borderWidth,
      ),
      gapPadding: borderRadius,
      borderRadius: BorderRadius.circular(borderRadius),
    );

    textColor??= getIt<AppColor>().ink;
    labelTextColor??= textColor;
    hintTextColor??=Color.lerp(textColor, Colors.transparent, 0.5);
    errorTextColor??= Colors.red;
    textLineHeight??= 1.2;
    textSize??= DefaultTextSizes.medium.value;
    labelTextSize??= textSize;
    hintTextSize??= DefaultTextSizes.medium.value;
    errorTextSize??= DefaultTextSizes.small.value;
    textWeight??= DefaultTextWeight.regular.value;
    labelTextWeight??= textWeight;
    hintTextWeight??= DefaultTextWeight.regular.value;
    errorTextWeight??= DefaultTextWeight.regular.value;

    TextStyle textStyle = TextStyle(
      color: textColor,
      height: textLineHeight,
      fontFamily: textFamily,
      fontSize: textSize,
      fontWeight: textWeight,
    );
    TextStyle labelStyle = TextStyle(
      color: labelTextColor,
      height: textLineHeight,
      fontFamily: textFamily,
      fontSize: labelTextSize,
      fontWeight: labelTextWeight,
    );
    TextStyle hintStyle = TextStyle(
      color: hintTextColor,
      height: textLineHeight,
      fontFamily: textFamily,
      fontSize: hintTextSize,
      fontWeight: hintTextWeight,
    );
    TextStyle errorStyle = TextStyle(
      color: errorTextColor,
      height: textLineHeight,
      fontFamily: textFamily,
      fontSize: errorTextSize,
      fontWeight: errorTextWeight,
    );
    if(required && label!=null){
      label+="*";
    }
    return TextFieldWidget._(
      unique,
      focusNodeController,
      prefixWidgetIcon,
      suffixWidgetIcon,
      paddingHorizontal,
      paddingVertical,
      marginHorizontal,
      elevation,
      elevationColor,
      backgroundColor,
      placeholder,
      label,
      initialValue,
      textInputType,
      autoValidateRegex,
      validateRegex,
      inputAction,
      required,
      obscured,
      border,
      borderFocused,
      minLines,
      maxLines,
      textStyle,
      labelStyle,
      hintStyle,
      errorStyle,
    );
  }
  TextFieldWidget._(
    this.unique,
    this.focusNodeController,
    this.prefixIcon,
    this.suffixIcon,
    this.paddingHorizontal,
    this.paddingVertical,
    this.marginHorizontal,
    this.elevation,
    this.elevationColor,
    this.backgroundColor,
    this.placeholder,
    this.label,
    this.initialValue,
    this.textInputType,
    this.autoValidateRegex,
    this.validateRegex,
    this.textInputAction,
    this.required,
    this.obscured,
    this.border,
    this.borderFocused,
    this.minLines,
    this.maxLines,
    this.textStyle,
    this.labelStyle,
    this.hintStyle,
    this.errorStyle,
  ):error = ValueNotifier(""),
  submitted = ValueNotifier(false),
  editingController = TextEditingController(text: initialValue),
  focusNode = FocusNode(),
  super(key: Key(unique)){
    focusNodeController.focusList.add(CustomFocus(focusNode, unique));
    print(focusNodeController.focusList);
    editingController.addListener(() {
      if(!required) return;
      bool allMatches = true;
      if(submitted.value){
        validateRegex.forEach((key, value) {
          if(!RegExp(key).hasMatch(editingController.text)){
            allMatches = false;
            error.value = value;
          }
        });
      }else{
        autoValidateRegex.forEach((key, value) {
          if(!RegExp(key).hasMatch(editingController.text)){
            allMatches = false;
            error.value = value;
          }
        });
      }
      if(allMatches) error.value = "";
    });
    submitted.addListener(() {
      if(!required) return;
      if(submitted.value) {
        bool allMatches = true;
        validateRegex.forEach((key, value) {
          if (!RegExp(key).hasMatch(editingController.text)) {
            allMatches = false;
            error.value = value;
          }
        });
        if (allMatches) error.value = "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: marginHorizontal??0),
      child: Material(
        elevation: elevation ?? 0,
        shadowColor: elevationColor,
        child: Column(
          children: [
            ValueListenableBuilder(
                valueListenable: obscured,
                builder:(context, value, _) {
                  print("nnnnnnn");
                  return TextField(
                    minLines: minLines,
                    maxLines: maxLines,
                    textInputAction: textInputAction,
                    obscureText: value,
                    controller: editingController,
                    clipBehavior: Clip.antiAlias,
                    onTapOutside: (event) {
                      FocusScope.of(context).unfocus();
                    },
                    expands: false,
                    style: textStyle,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: label,
                      hintText: placeholder,
                      errorStyle: errorStyle,
                      labelStyle: labelStyle,
                      hintStyle: hintStyle,
                      alignLabelWithHint: true,
                      prefixIconConstraints: BoxConstraints(),
                      suffixIconConstraints: BoxConstraints(),
                      prefixIcon: prefixIcon == null ? null : Padding(
                        padding: EdgeInsetsExtension.custom(
                          horizontal: paddingHorizontal,
                          vertical: paddingVertical,
                          right: 0,
                        ),
                        child: prefixIcon,
                      ),
                      suffixIcon: suffixIcon == null ? null : Padding(
                        padding: EdgeInsetsExtension.custom(
                          horizontal: paddingHorizontal,
                          vertical: paddingVertical,
                          left: 0,
                        ),
                        child: suffixIcon,
                      ),
                      isDense: true,
                      filled: true,
                      fillColor: backgroundColor,
                      enabledBorder: border,
                      focusedBorder: borderFocused,
                      constraints: BoxConstraints(
                      ),
                      contentPadding: EdgeInsetsExtension.custom(
                        horizontal: paddingHorizontal,
                        vertical: paddingVertical,
                      ),
                    ),
                    onEditingComplete: () {
                      FocusNode? nextField = focusNodeController.focusList.firstWhere((element) => element.unique == unique).next?.focusNode;
                      print(nextField);
                      if(nextField!= null){
                        FocusScope.of(context).requestFocus(nextField);
                      }else{
                        FocusScope.of(context).unfocus();
                      }
                    },
                  );
                }
            ),
            ValueListenableBuilder(
              valueListenable: error,
              builder: (context, value, _) {
                if(value.isEmpty){
                  return Container();
                }
                return Container(
                  margin: EdgeInsets.only(left: paddingHorizontal),
                  alignment: Alignment.centerLeft,
                  child: TextWidget.fromStyle(
                    text: value,
                    textStyle: errorStyle,
                  ),
                );
              },
            ),
            Container(
              height: 10,
            )
          ],
        ),
      ),
    );
  }

  void reset(){
    submitted.value = false;
    obscured.value = false;
    error.value = "";
    editingController.text = "";
  }
}
class CustomFocus extends LinkedListEntry<CustomFocus>{
  final String unique;
  final FocusNode focusNode;
  CustomFocus(this.focusNode, this.unique);
  @override
  String toString() {
    return {
      unique,
      focusNode.toString()
    }.toString();
  }
}

class FocusNodeController{
  LinkedList<CustomFocus> focusList;
  FocusNodeController(): focusList = LinkedList();

}