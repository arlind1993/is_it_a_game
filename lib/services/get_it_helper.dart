import 'package:game_template/screens/cards/card_constants.dart';
import 'package:game_template/screens/games/chess/logic/chess_internet.dart';
import 'package:game_template/screens/games/chess/models/chess_constants.dart';
import 'package:game_template/screens/games/sudoku/models/sudoku_constants.dart';
import 'package:game_template/screens/routes_controller.dart';
import 'package:game_template/screens/screens_controller.dart';
import 'package:game_template/services/firebase/firebase_fcm.dart';
import 'package:game_template/services/firebase/firebase_rtdb.dart';
import 'package:game_template/services/firebase/internet_connection.dart';
import 'package:get_it/get_it.dart';

import 'package:game_template/services/app_styles/app_color.dart';
import 'package:game_template/services/helpers/transition.dart';
import 'firebase/firebase_auth.dart';
import 'helpers/snack_bar.dart';

final GetIt getIt = GetIt.instance;

getItSetUp() async{
  getIt.registerLazySingleton<AppColor>(() => AppColor());
  getIt.registerLazySingleton<CardConstants>(() => CardConstants());
  getIt.registerLazySingleton<ChessConstants>(() => ChessConstants());
  getIt.registerLazySingleton<SudokuConstants>(() => SudokuConstants());
  getIt.registerLazySingleton<CustomTransitionBuilder>(() => CustomTransitionBuilder());
  getIt.registerLazySingleton<CustomSnackBar>(() => CustomSnackBar());
  getIt.registerLazySingleton<RoutesController>(() => RoutesController());
  getIt.registerLazySingleton<ScreensController>(() => ScreensController("/"));


  getIt.registerSingletonAsync<InternetConnection>(() => InternetConnection().initialise());
  getIt.registerSingletonAsync<FirebaseAuthUser>(() => FirebaseAuthUser().initialise());
  getIt.registerSingletonAsync<FirebaseRTDB>(() => FirebaseRTDB().initialise());
  getIt.registerSingletonAsync<FirebaseNotifications>(() => FirebaseNotifications().initialise());
  getIt.registerLazySingleton<ChessInternet>(() => ChessInternet());

}