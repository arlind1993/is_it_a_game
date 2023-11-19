import 'package:flutter/material.dart';
class CustomEdgeInsets extends EdgeInsets{
  CustomEdgeInsets._(
    double left,
    double right,
    double bottom,
    double top,
  ) : super.fromLTRB(left, top, right, bottom);

  factory CustomEdgeInsets({
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
    return CustomEdgeInsets._(_left, _top, _right, _bottom);
  }
}