import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseNotifications{
  late FirebaseMessaging messaging;
  String? token;

  Future initialise() async{
    messaging = FirebaseMessaging.instance;
    await notificationPermissions();

    messaging.setForegroundNotificationPresentationOptions(
      sound: true,
      badge: true,
      alert: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {});

    FirebaseMessaging.onMessageOpenedApp.listen((message) {});

  }

  notificationPermissions() async{
    log("Notification should pop up");
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: true,
      sound: true,
    );

    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      log("User granted permission");
    }else if(settings.authorizationStatus == AuthorizationStatus.provisional){
      log("User granted provisional permission");
    }else{
      log("User declined or hasn't accepted permission");
    }
  }


}