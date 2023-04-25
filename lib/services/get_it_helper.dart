import 'package:firebase_core/firebase_core.dart';
import 'package:game_template/services/firebase/firebase_fcm.dart';
import 'package:game_template/services/firebase/firebase_rtdb.dart';
import 'package:game_template/services/helpers/internet_connection.dart';
import 'package:get_it/get_it.dart';

import 'package:game_template/services/app_styles/app_color.dart';
import 'package:game_template/services/helpers/transition.dart';
import 'firebase/firebase_auth.dart';
import 'helpers/snack_bar.dart';

final GetIt getIt = GetIt.instance;

getItSetUp() async{
  getIt.registerLazySingleton<AppColor>(() => AppColor());
  getIt.registerLazySingleton<CustomTransitionBuilder>(() => CustomTransitionBuilder());
  getIt.registerLazySingleton<CustomSnackBar>(() => CustomSnackBar());
  getIt.registerLazySingletonAsync<InternetConnection>(() async => await InternetConnection()..initialise());
  getIt.registerLazySingletonAsync<FirebaseAuthUser>(() async => await FirebaseAuthUser()..initialise());
  getIt.registerLazySingletonAsync<FirebaseRTDB>(() async => await FirebaseRTDB()..initialise());
  getIt.registerLazySingletonAsync<FirebaseNotifications>(() async => await FirebaseNotifications()..initialise());
}