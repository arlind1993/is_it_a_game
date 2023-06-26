import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:game_template/widgets/text_widget.dart';

import '../services/app_styles/app_color.dart';
import '../services/get_it_helper.dart';

class TextFieldWidget extends StatelessWidget {

  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double? padding;
  final double? marginHorizontal;
  final double? elevation;
  final Color? elevationColor;

  factory TextFieldWidget({
    double? iconSize,
    Widget? prefixWidgetIcon,
    Widget? suffixWidgetIcon,
    IconData? prefixIcon,
    IconData? suffixIcon,
    Color? prefixColor,
    Color? suffixColor,
    double? padding,
    double? marginHorizontal,
    double? elevation,
    Color? elevationColor,
  }){
    iconSize ??= DefaultTextSizes.medium.value;
    prefixColor ??= getIt<AppColor>().ink;
    suffixColor ??= getIt<AppColor>().ink;
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
    return TextFieldWidget._(
      prefixWidgetIcon,
      suffixWidgetIcon,
      padding,
      marginHorizontal,
      elevation,
      elevationColor,
    );
  }
  TextFieldWidget._(
    this.prefixIcon,
    this.suffixIcon,
    this.padding,
    this.marginHorizontal,
    this.elevation,
    this.elevationColor
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: marginHorizontal??0),
      child: Material(
        elevation: elevation ?? 0,
        shadowColor: elevationColor,
        clipBehavior: Clip.antiAlias,
        child: Container(
          child: TextField,
        ),
      ),
    );
  }

  // VoidCallback action;
  // IconData? prefixIcon;
  // late double fontSize;
  // double? width;
  // double? buttonSize;
  // String placeholder;
  // Color backgroundColor;
  // Color foregroundColor;
  // late Color iconColor;
  // late FocusNode focusNode;
  // late TextEditingController textEditCon;
  // Map<String, String> validate;
  // Map<String, String> validateAuto;
  // bool required;
  // bool totalValidation = false;
  // bool isTextArea;
  //
  // TextUserForm({
  //   this.isTextArea = false,
  //   this.prefixIcon,
  //   this.buttonSize,
  //   required this.placeholder,
  //   required this.action,
  //   double? fontSize,
  //   this.backgroundColor=Colors.white,
  //   this.foregroundColor=Colors.black,
  //   Color? iconColor,
  //   this.validate= const{},
  //   this.validateAuto = const{},
  //   this.required = true,
  //
  // }){
  //   this.fontSize = fontSize ?? AppProperties.instance.sizes.appFontSize;
  //   this.iconColor = iconColor ?? foregroundColor;
  //   focusNode=FocusNode();
  //   textEditCon=TextEditingController();
  // }
  //
  // refresh(){
  //   String temp=textEditCon.text;
  //   textEditCon.text+=" ";
  //   textEditCon.text=temp;
  // }
  //
  // bool isValidated(){
  //   totalValidation=true;
  //   if(required){
  //     if(textEditCon.text == null || textEditCon.text.isEmpty){
  //       return false;
  //     }
  //     String? errorMessage;
  //     for (MapEntry<String,String> element in validate.entries) {
  //       if(!textEditCon.text.contains(RegExp(element.key))){
  //         errorMessage=element.value;
  //         break;
  //       }
  //     }
  //     return errorMessage==null;
  //   }
  //   return true;
  // }
  //
  // @override
  // Widget build(BuildContext context) {
  //   log('text_built');
  //   return Container(
  //       height: AppProperties.instance.sizes.appFontSize * (isTextArea? 8 :5),
  //       decoration: BoxDecoration(
  //         boxShadow: [
  //           BoxShadow(
  //               blurRadius: AppProperties.instance.sizes.appFontSize,
  //               offset: Offset(0, (required ? -1 : 1) *
  //                   AppProperties.instance.sizes.appFontSize/2),
  //               color: Color.fromRGBO(0,0,0,0.1),
  //               spreadRadius: -AppProperties.instance.sizes.appFontSize
  //           ),
  //         ],
  //       ),
  //       child: TextFormField(
  //         minLines: isTextArea ? 3 : 1,
  //         maxLines: isTextArea ? 3 : 1,
  //         controller: textEditCon,
  //         focusNode: focusNode,
  //         style: TextStyle(
  //             fontFamily: "Avenir",
  //             fontSize: fontSize,
  //             color: foregroundColor,
  //             height: AppProperties.instance.spacings.lineHeightCentering
  //         ),
  //         decoration: InputDecoration(
  //           errorStyle: TextStyle(
  //               height: 0.5,
  //               color: Colors.red[700]
  //           ),
  //           contentPadding: EdgeInsets.all(
  //               AppProperties.instance.spacings.inputVHPadding
  //           ),
  //           border: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(
  //                   AppProperties.instance.spacings.inputBorderRadius
  //               ),
  //               borderSide: BorderSide(
  //                 color: Colors.grey,
  //               )
  //           ),
  //           isDense: true,
  //           prefixIconConstraints: BoxConstraints(),
  //           hintText: placeholder,
  //           hintStyle: TextStyle(
  //             color: Color.lerp(foregroundColor, backgroundColor,0.5),
  //           ),
  //           prefixIcon: prefixIcon == null ? null : Padding(
  //             padding: EdgeInsets.symmetric(
  //                 horizontal: AppProperties.instance.spacings.inputVHPadding
  //             ),
  //             child: Icon(
  //               prefixIcon,
  //               size: buttonSize,
  //               color: iconColor,
  //             ),
  //           ),
  //           filled: true,
  //           fillColor: backgroundColor,
  //         ),
  //         keyboardType: TextInputType.text,
  //         validator: (value) {
  //           if(required){
  //             for (MapEntry<String,String> element in validateAuto.entries) {
  //               if(value!=null && value.isNotEmpty) {
  //                 if (!value.contains(RegExp(element.key))) {
  //                   return element.value;
  //                 }
  //               }
  //             }
  //             if(totalValidation) {
  //               if (value!.isEmpty) {
  //                 return "$placeholder is empty";
  //               }
  //               for (MapEntry<String, String> element in validate.entries) {
  //                 if (value != null && value.isNotEmpty) {
  //                   if (!value.contains(RegExp(element.key))) {
  //                     return element.value;
  //                   }
  //                 }
  //               }
  //             }
  //           }
  //           return null;
  //         },
  //         autovalidateMode: AutovalidateMode.always,
  //         onEditingComplete: () {
  //           action();
  //         },
  //         onTap: () {
  //           log("userForm taped");
  //         },
  //         textInputAction: TextInputAction.next,
  //       )
  //   );
  // }
}