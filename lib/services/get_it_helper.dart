import 'package:game_template/screens/screens_controller.dart';
import 'package:game_template/services/firebase/firebase_fcm.dart';
import 'package:game_template/services/firebase/firebase_rtdb.dart';
import 'package:game_template/services/firebase/internet_connection.dart';
import 'package:get_it/get_it.dart';

import 'package:game_template/services/app_styles/app_color.dart';
import 'package:game_template/services/helpers/transition.dart';
import 'firebase/firebase_auth.dart';
import 'helpers/snack_bar.dart';


final Global global = Global.singleton();
class Global{
  factory Global.singleton() => Global._();
  Global._();

  final GetIt getIt = GetIt.instance;
  getItSetUp() async{
    getIt.registerLazySingleton<AppColor>(() => AppColor.singleton());
    getIt.registerLazySingleton<CustomTransitionBuilder>(() => CustomTransitionBuilder.singleton());
    getIt.registerLazySingleton<CustomSnackBar>(() => CustomSnackBar.singleton());
    getIt.registerLazySingleton<ScreensController>(() => ScreensController.singleton());
    getIt.registerLazySingleton<FirebaseAuthUser>(() => FirebaseAuthUser.singleton());
    getIt.registerLazySingleton<FirebaseRTDB>(() => FirebaseRTDB.singleton());
    getIt.registerSingletonAsync<InternetConnection>(() => InternetConnection.singleton().initialise(), signalsReady: true);
    getIt.registerSingletonAsync<FirebaseNotifications>(() => FirebaseNotifications.singleton().initialise(), signalsReady: true);
    return getIt.allReady();
  }

  AppColor get color => getIt<AppColor>();
  CustomTransitionBuilder get transitionBuilder => getIt<CustomTransitionBuilder>();
  CustomSnackBar get snackBar => getIt<CustomSnackBar>();
  ScreensController get screenController => getIt<ScreensController>();
  FirebaseAuthUser get auth => getIt<FirebaseAuthUser>();
  FirebaseRTDB get db => getIt<FirebaseRTDB>();
  FirebaseNotifications get notification => getIt<FirebaseNotifications>();
  InternetConnection get internet => getIt<InternetConnection>();
}



