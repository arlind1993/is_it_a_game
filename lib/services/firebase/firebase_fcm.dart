import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma("vm:entry-point")
void _handleMessages(RemoteMessage event) {

}

class FirebaseNotifications{
  factory FirebaseNotifications.singleton() => FirebaseNotifications._();
  FirebaseNotifications._();

  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? token;

  
  
  Future<FirebaseNotifications> initialise() async{
    await notificationPermissions();

    messaging.setForegroundNotificationPresentationOptions(
      sound: true,
      badge: true,
      alert: true,
    );

    FirebaseMessaging.onMessage.listen(_handleMessages);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessages);
    return this;
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