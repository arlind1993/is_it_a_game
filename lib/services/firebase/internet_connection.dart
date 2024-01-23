import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class InternetConnection extends ValueNotifier<bool>{
  factory InternetConnection.singleton() => InternetConnection._(true);
  InternetConnection._(super._value);

  Future<InternetConnection> initialise() async{
    final Connectivity connectivity = Connectivity();
    if(kDebugMode) logChanges();
    connectivity.onConnectivityChanged.listen((event){
      value = hasConnection(event);
    });
    return connectivity.checkConnectivity().then((event) async{
      value = hasConnection(event);
    }).then((value) => this);
  }

  void logChanges() => addListener(() {
    print("Connected: $value");
  });


  bool hasConnection(ConnectivityResult connectivityResult){
    return connectivityResult==ConnectivityResult.mobile || connectivityResult==ConnectivityResult.wifi;
  }
}