import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_template/provider/app_lifecycle.dart';
import 'package:game_template/provider/settings_controller.dart';
import 'package:game_template/screens/game_selector.dart';
import 'package:game_template/screens/games/chess/main_chess_screen.dart';
import 'package:game_template/screens/games/chess/chess_init_screen.dart';
import 'package:game_template/screens/games/murlan/murlan.dart';
import 'package:game_template/screens/games/poker/poker.dart';
import 'package:game_template/screens/games/sudoku/sudoku.dart';
import 'package:game_template/screens/main_menu_screen.dart';
import 'package:game_template/screens/settings_screen.dart';
import 'package:game_template/services/app_styles/app_color.dart';
import 'package:game_template/services/get_it_helper.dart';
import 'package:game_template/services/helpers/snack_bar.dart';
import 'package:game_template/services/helpers/transition.dart';

import 'package:go_router/go_router.dart';
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
  static final _router = GoRouter(
    routes: [
      GoRoute(
          path: '/',
          builder: (context, state) {
            return const MainMenuScreen(key: Key('main menu'));
          },
          routes: [
            GoRoute(
                path: 'game_selector',
                pageBuilder: (context, state) {
                  return getIt<CustomTransitionBuilder>().build(
                    child: GameSelector(key: Key('game selection')),
                    color: getIt<AppColor>().greenContrast
                  );
                },
                routes: [
                  GoRoute(
                    path: 'chess',
                    pageBuilder: (context, state) {
                      return getIt<CustomTransitionBuilder>().build<void>(
                        child: MainChessScreen(
                          key: const Key('chess'),
                        ),
                        color: getIt<AppColor>().greenContrast,
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'play',
                        pageBuilder: (context, state) {
                          return getIt<CustomTransitionBuilder>().build<void>(
                            child: ChessInitScreen(
                              key: const Key('chess play'),
                            ),
                            color: getIt<AppColor>().greenContrast,
                          );
                        },
                      )
                    ]
                  ),
                  GoRoute(
                    path: 'murlan',
                    pageBuilder: (context, state) {
                      return getIt<CustomTransitionBuilder>().build<void>(
                        child: MainMurlanScreen(
                          key: const Key('murlan'),
                        ),
                        color: getIt<AppColor>().greenContrast,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'poker',
                    pageBuilder: (context, state) {
                      return getIt<CustomTransitionBuilder>().build<void>(
                        child: MainPokerScreen(
                          key: const Key('poker'),
                        ),
                        color: getIt<AppColor>().greenContrast,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'sudoku',
                    pageBuilder: (context, state) {
                      return getIt<CustomTransitionBuilder>().build<void>(
                        child: MainSudokuScreen(
                          key: const Key('sudoku'),
                        ),
                        color: getIt<AppColor>().greenContrast,
                      );
                    },
                  ),
                ]),
            GoRoute(
              path: 'settings',
              builder: (context, state) {
                return const SettingsScreen(key: Key('settings'));
              },
            ),
          ]
      ),
    ],
  );

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
                seedColor: getIt.get<AppColor>().beigeMain,
                background: getIt<AppColor>().greenContrast,
              ),
              textTheme: TextTheme(
                bodyMedium: TextStyle(
                  color: getIt.get<AppColor>().ink,
                ),
              ),
              useMaterial3: true,
            ),
            routeInformationProvider: _router.routeInformationProvider,
            routeInformationParser: _router.routeInformationParser,
            routerDelegate: _router.routerDelegate,
            scaffoldMessengerKey: getIt.get<CustomSnackBar>().scaffoldMessengerKey,
          );
        }),
      ),
    );
  }
}
