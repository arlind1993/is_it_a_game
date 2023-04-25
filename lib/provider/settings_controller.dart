import 'package:flutter/material.dart';

class SettingsController extends ChangeNotifier{

  bool muted = false;

  setMuted(bool muted){
    if(muted!=this.muted){
      this.muted = muted;
      notifyListeners();
    }
  }
}