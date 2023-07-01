import 'package:flutter/cupertino.dart';

extension EdgeInsetsExtension on EdgeInsets{
  static EdgeInsets custom({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? right,
    double? bottom,
    double? top,
  }){
    double _left = 0;
    double _right = 0;
    double _bottom = 0;
    double _top = 0;
    if(all!=null){
      _left = all;
      _right = all;
      _bottom = all;
      _top = all;
    }
    if(horizontal!=null){
      _left = horizontal;
      _right = horizontal;
    }
    if(vertical!=null){
      _bottom = vertical;
      _top = vertical;
    }
    if(left!=null) _left = left;
    if(right!=null) _right = right;
    if(top!=null) _top = top;
    if(bottom!=null) _bottom = bottom;
    return EdgeInsets.fromLTRB(_left, _top, _right, _bottom);
  }
}