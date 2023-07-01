import 'package:flutter/material.dart';
import 'package:game_template/screens/screens_controller.dart';
import 'package:game_template/services/get_it_helper.dart';
import 'package:game_template/widgets/bottom_nav_bar.dart';

class ScaffoldScreen extends StatelessWidget {
  final Widget child;
  AppBar? appBar;
  final bool visibleBottomBar;
  final bool obstructViewBottomBar;
  String pathOnBackAction;
  Map? dialogMustStay;

  ScaffoldScreen({
    this.appBar,
    this.dialogMustStay,
    required this.pathOnBackAction,
    required this.child,
    this.visibleBottomBar = false,
    this.obstructViewBottomBar = false
  }): super(key: child.key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        getIt<ScreensController>().value = pathOnBackAction;
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Builder(
          builder: (context) {
            BottomNavBar navBar = BottomNavBar(visible: visibleBottomBar);
            if(visibleBottomBar && !obstructViewBottomBar){
              return Stack(
                children: [
                  Positioned.fill(
                    child: SafeArea(
                      child: child
                    )
                  ),
                  Positioned(
                    bottom: MediaQuery.of(context).padding.bottom,
                    left: 0,
                    right: 0,
                    child: navBar
                  ),
                ],
              );
            }else{
              return Column(
                children: [
                  Expanded(
                    child: SafeArea(
                      child: child,
                    )
                  ),
                  navBar,
                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom,
                  )
                ],
              );
            }
          }
        ),
      ),
    );
  }
}
