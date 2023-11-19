import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_template/provider/app_lifecycle.dart';
import 'package:game_template/provider/settings_controller.dart';
import 'package:game_template/screens/routes_controller.dart';
import 'package:game_template/services/app_styles/app_color.dart';
import 'package:game_template/services/extensions/string_extensions.dart';
import 'package:game_template/services/get_it_helper.dart';
import 'package:game_template/services/helpers/snack_bar.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'services/firebase/firebase_crash.dart';

import 'services/extensions/logging_extensions.dart';


Logger _log = Logger('main');
Future<void> main() async {

  FirebaseCrashlytics? crashlytics;
  if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      crashlytics = FirebaseCrashlytics.instance;
    } catch (e) {
      _log.printLog(Level.WARNING, "Firebase couldn't be initialized", stacktrace: e.toString());
    }
  }

  await guardWithCrashlytics(
    guardedMain,
    crashlytics: crashlytics,
  );
}

void guardedMain() {
  if (kReleaseMode) {
    Logger.root.level = Level.WARNING;
  }

  WidgetsFlutterBinding.ensureInitialized();

  _log.info('Going full screen');
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );
  getItSetUp();

  runApp(
    MyApp(),
  );
}



class MyApp extends StatelessWidget {

  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppLifecycleObserver(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => SettingsController()),
        ],
        child: Builder(builder: (context) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Is it a Game?',
            theme: ThemeData.from(
              colorScheme: ColorScheme.fromSeed(
                seedColor: getIt<AppColor>().beigeMain,
                background: getIt<AppColor>().greenContrast,
              ),
              textTheme: TextTheme(
                bodyMedium: TextStyle(
                  color: getIt<AppColor>().ink,
                ),
              ),
              useMaterial3: true,
            ),
            routeInformationProvider: getIt<RoutesController>().router.routeInformationProvider,
            routeInformationParser: getIt<RoutesController>().router.routeInformationParser,
            routerDelegate: getIt<RoutesController>().router.routerDelegate,
            scaffoldMessengerKey: getIt<CustomSnackBar>().scaffoldMessengerKey,
          );
        }),
      ),
    );
  }
}
