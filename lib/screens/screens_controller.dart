import 'package:flutter/material.dart';

class ScreensController extends ValueNotifier<String>{
  factory ScreensController.singleton() => ScreensController._("/");
  ScreensController._(super.value);
}
