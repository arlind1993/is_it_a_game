import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_template/provider/app_lifecycle.dart';
import 'package:game_template/provider/settings_controller.dart';
import 'package:game_template/screens/routes_controller.dart';
import 'package:game_template/services/get_it_helper.dart';
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

  runApp(
    MyApp(routesController: RoutesController()),
  );
}



class MyApp extends StatelessWidget {
  final RoutesController routesController;
  const MyApp({
    super.key,
    required this.routesController
  });

  @override
  Widget build(BuildContext context) {
    return AppLifecycleObserver(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => SettingsController()),
        ],
        child: FutureBuilder(
          future: global.getItSetUp(),
          builder: (context, snapshot) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'Is it a Game?',
              theme: ThemeData.from(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: global.color.beigeMain,
                  background: global.color.greenContrast,
                ),
                textTheme: TextTheme(
                  bodyMedium: TextStyle(
                    color: global.color.ink,
                  ),
                ),
                useMaterial3: true,
              ),
              routeInformationProvider: routesController.router.routeInformationProvider,
              routeInformationParser: routesController.router.routeInformationParser,
              routerDelegate: routesController.router.routerDelegate,
              scaffoldMessengerKey: global.snackBar.scaffoldMessengerKey,
            );
          }
        ),
      ),
    );
  }
}
