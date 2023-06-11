import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';

class InternetConnection{
  static InternetConnection _internetConnection = InternetConnection._();
  InternetConnection._();
  factory InternetConnection(){
    return _internetConnection;
  }

  final Connectivity connectivity = Connectivity();
  late Stream<ConnectivityResult> connectivityStream;
  bool connected = true;


  initialise() async{
    ConnectivityResult cr = await connectivity.checkConnectivity();
    connected = await isConnected(connectivityResult: cr);
    connectivityStream = connectivity.onConnectivityChanged.asBroadcastStream();
    connectivityStream.listen((event) async{
      connected = await isConnected(connectivityResult: cr);
      log("Connected: $connected");
    });
  }

  Future<bool> isConnected({ConnectivityResult? connectivityResult}) async {
    if(connectivityResult == null){
      await Future.delayed(Duration.zero,() async{
        connectivityResult = await connectivity.checkConnectivity();
      });
    }
    return connectivityResult==ConnectivityResult.mobile
        || connectivityResult==ConnectivityResult.wifi;
  }

  Future<bool> isNotConnected({ConnectivityResult? connectivityResult}) async {
    return !await isConnected(connectivityResult: connectivityResult);
  }
}