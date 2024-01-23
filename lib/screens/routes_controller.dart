import 'package:flutter/cupertino.dart';
import 'package:game_template/screens/account/account_screen.dart';
import 'package:game_template/screens/scaffold_screen.dart';
import 'package:go_router/go_router.dart';

import '../services/get_it_helper.dart';
import 'account/settings_screen.dart';
import 'games/game_selector_screen.dart';
import 'games/murlan/screen/main_murlan_screen.dart';
import 'games/poker/screen/main_poker_screen.dart';
import 'main_menu_screen.dart';

class RoutesController{
  final GoRouter router = GoRouter(
    routes: [
      GoRoute(
          path: '/',
          pageBuilder: (context, state) {
            return NoTransitionPage(
              child: ScaffoldScreen(
                pathOnBackAction: '/',
                obstructViewBottomBar: true,
                visibleBottomBar: false,
                child: MainMenuScreen(key: Key('main menu'))
              ),
            );
          },
          routes: [
            GoRoute(
                path: 'play',
                pageBuilder: (context, state) {
                  return NoTransitionPage(
                      child: ScaffoldScreen(
                        pathOnBackAction: '/',
                        obstructViewBottomBar: true,
                        visibleBottomBar: true,
                        child: GameSelector(
                          key: Key('game selection')
                        )
                      ),
                      //color: getIt<AppColor>().greenContrast
                  );
                },
                routes: [
                  GoRoute(
                    path: 'murlan',
                    pageBuilder: (context, state) {
                      return global.transitionBuilder.build<void>(
                        child: ScaffoldScreen(
                          pathOnBackAction: '/play',
                          obstructViewBottomBar: true,
                          visibleBottomBar: false,
                          child: MainMurlanScreen(
                            key: const Key('murlan'),
                          ),
                        ),
                        color: global.color.greenContrast,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'poker',
                    pageBuilder: (context, state) {
                      return global.transitionBuilder.build<void>(
                        child: ScaffoldScreen(
                          pathOnBackAction: '/play',
                          obstructViewBottomBar: true,
                          visibleBottomBar: false,
                          child: MainPokerScreen(
                            key: const Key('poker'),
                          ),
                        ),
                        color: global.color.greenContrast,
                      );
                    },
                  ),
                ]
            ),
            GoRoute(
              path: 'offline',
              pageBuilder: (context, state) {
                return NoTransitionPage(
                  child: ScaffoldScreen(
                    pathOnBackAction: '/',
                    obstructViewBottomBar: true,
                    visibleBottomBar: true,
                    child: SettingsScreen(
                      key: const Key('offline')
                    )
                  ),
                );
              },
            ),
            GoRoute(
              path: 'profile',

              pageBuilder: (context, state) {
                print("reload");
                return NoTransitionPage(
                  key: UniqueKey(),
                  child: ScaffoldScreen(
                    pathOnBackAction: '/',
                    obstructViewBottomBar: true,
                    visibleBottomBar: true,
                    child: ProfileScreen(
                    )
                  ),
                );
              },
              routes: [
                GoRoute(
                  path: 'settings',
                  builder: (context, state) {
                    return ScaffoldScreen(
                      pathOnBackAction: '/profile',
                      obstructViewBottomBar: true,
                      visibleBottomBar: false,
                      child: SettingsScreen(
                          key: Key('settings')
                      ),
                    );
                  },
                ),
              ]
            ),
          ]
      ),
    ],
  );
}