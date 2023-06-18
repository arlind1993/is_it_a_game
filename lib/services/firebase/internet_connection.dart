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


  Future<InternetConnection> initialise() async{
    await connectivity.checkConnectivity().then((value) async{
      connected = hasConnection(value);
    });
    connectivityStream = connectivity.onConnectivityChanged.asBroadcastStream();
    connectivityStream.listen((event) async{
      connected = hasConnection(event);
      log("Connected: $connected");
    });
    return this;
  }
  bool hasConnection(ConnectivityResult connectivityResult){
    return connectivityResult==ConnectivityResult.mobile || connectivityResult==ConnectivityResult.wifi;
  }

  Future<bool> isConnected() async {
    return connectivity.checkConnectivity().then((value) => hasConnection(value));
  }

  Future<bool> isNotConnected() async {
    return connectivity.checkConnectivity().then((value) => !hasConnection(value));
  }
}