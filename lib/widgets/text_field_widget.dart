import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'text_widget.dart';
import 'custom_edge_insets.dart';

import '../services/app_styles/app_color.dart';
import '../services/get_it_helper.dart';
enum TextFieldTypes{
  text(
      inputType: TextInputType.text,
      automaticRegexValidation: const{r"^.*$": "Text is not a paragraph",},
      fullRegexValidation: const MapEntry(r"^.+", "The text is empty")
  ),
  paragraph(
      inputType: TextInputType.multiline,
      automaticRegexValidation: const{},
      fullRegexValidation: const MapEntry(r"^(.|\n)+$", "The paragraph is empty")
  ),
  email(
      inputType: TextInputType.emailAddress,
      automaticRegexValidation: const{
        "^((?![${emailNonConsecutive}][${emailNonConsecutive}]).)*\$":"These characters shouldn't be inputted consecutively: ., -, and _!",
        r"^([^\@\.\_\-].*[^\@\.\_\-])|[^\@\.\_\-]?$":"These characters shouldn't be inputted in the beginning or the end: ., -, and _!",
        "^[${allAlphabetNumbers}${emailSpecialChars}${emailNonConsecutive}\\@]*\$": "Invalid Character/s",
        r"^[^@]*@?[^@]*$": "There shouldn't be two '@'!",
        r"(^(?=^[^@]*)[^@]*$)|(^.{0,64}@.*$)": "There shouldn't be more than 64 characters before '@'!",
        r"(^(?=^[^@]*)[^@]*$)|(^.*@.{0,253}$)": "There shouldn't be more than 253 characters after '@'!",
        "(^(?=^[^@]*)[^@]*\$)|(^.*@(([${allAlphabetNumbers}\\-]{2,})([\\.]))*([${allAlphabetNumbers}\\-]*)\$)": "There should more than two characters after . in domain section of the email!",
      },
      fullRegexValidation: const MapEntry("^(?!^.{65,}\\@)(([${allAlphabetNumbers}${emailSpecialChars}]+)([${emailNonConsecutive}])?)*([${allAlphabetNumbers}${emailSpecialChars}]+)(?!\\@.{256,}\$)\\@(([${allAlphabetNumbers}\\-]{2,})([\\.]))+([${allAlphabetNumbers}\\-]{2,})\$", "The email is not valid")
  ),
  password(
      inputType: TextInputType.visiblePassword,
      automaticRegexValidation: const{},
      fullRegexValidation: const MapEntry(r"^(?=.*[A-Za-z])(?=.*\d).{6,}$", "The password is not valid")
  ),
  number(
      inputType: TextInputType.numberWithOptions(signed: true, decimal: true),
      automaticRegexValidation: const{
        r"^[.,0-9]*$" : "Invalid characters!",
        r"^[^.,]*.?[^.,]*$" : "There more than one character of type '.' or ','!",
        r"^([^.,].*[^.,]|[^.,])$": "The character '.' or ',' shouldn't be in the beginning or end",
      },
      fullRegexValidation: const MapEntry(r"^[\d]+([.,][\d]+)?$", "The number is not valid")
  ),
  integer(
      inputType: TextInputType.numberWithOptions(signed: true),
      automaticRegexValidation: const{
        r"^[/d]*$" : "Invalid characters!",
      },
      fullRegexValidation: const MapEntry(r"^\d*$", "The integer is not valid")
  ),
  phone(
      inputType: TextInputType.phone,
      automaticRegexValidation: const{
        r"^[/d/+/- ]*$": "Invalid characters",
        r"^(?!--).*$": "Hyphens can't be inputted consecutively!",
        r"^(?!--)\+?(00)?([\d] {0,2}-? {0,2}){7,15}$": "No phone number can have more than 15 digits",
        r"^+?[^+]*$": "The character + can be inputted only in the begging",
      },
      fullRegexValidation: const MapEntry(r"^(?!--)\+?(00)?([\d] {0,2}-? {0,2}){6,14}\d$", "The phone is not valid")
  ),
  address(
      inputType: TextInputType.streetAddress,
      automaticRegexValidation: const{
        r"^[#\w\.\,\-]*$": "Invalid characters",
      },
      fullRegexValidation: const MapEntry("^[#\\w\\.\\,\\-\\'\\\"]+\$", "The address is not valid")
  );
  static const String allAlphabetNumbers = "0-9a-zA-Z";
  static const String emailSpecialChars = r"\!\#\$\%\&\'\*\/\=\?\^\`\{\|\}\(\)\[\]\<\>\,";
  static const String emailNonConsecutive = r"\_\.\-";
  const TextFieldTypes({
    required this.inputType,
    required this.automaticRegexValidation,
    required this.fullRegexValidation,
  });
  final TextInputType inputType;
  final Map<String, String> automaticRegexValidation;
  final MapEntry<String, String> fullRegexValidation;
}

class TextFieldWidget extends StatelessWidget {
  static final Color defaultColor = global.color.ink;
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
    iconColor ??= defaultColor;
    prefixColor ??= iconColor;
    suffixColor ??= iconColor;
    elevationColor ??= defaultColor;
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
      textInputType = textFieldTypes.inputType;
      autoValidateRegex = textFieldTypes.automaticRegexValidation;
      validateRegex = {textFieldTypes.fullRegexValidation.key: textFieldTypes.fullRegexValidation.value};
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
    borderColor??=defaultColor;
    borderFocusedColor??=borderColor;
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

    textColor??= defaultColor;
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
            return;
          }
        });
      }else{
        autoValidateRegex.forEach((key, value) {
          if(!RegExp(key).hasMatch(editingController.text)){
            allMatches = false;
            error.value = value;
            return;
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
            return;
          }
        });
        if (allMatches) error.value = "";
      }
    });
  }

  bool isValid(){
    if(!required) return true;
    bool allMatches = true;
    validateRegex.forEach((key, value) {
      print("$key -> ${editingController.text}");
      if (!RegExp(key).hasMatch(editingController.text)) {
        allMatches = false;
        return;
      }
    });
    return allMatches;
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
                      padding: CustomEdgeInsets(
                        horizontal: paddingHorizontal,
                        vertical: paddingVertical,
                        right: 0,
                      ),
                      child: prefixIcon,
                    ),
                    suffixIcon: suffixIcon == null ? null : Padding(
                      padding: CustomEdgeInsets(
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
                    contentPadding: CustomEdgeInsets(
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
            ),
          ],
        ),
      ),
    );
  }

  void reset(){
    submitted.value = false;
    obscured.value = true;
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