import 'package:flutter/material.dart';
import 'package:game_template/screens/screens_controller.dart';
import 'package:game_template/services/app_styles/app_color.dart';
import 'package:game_template/services/get_it_helper.dart';
import 'package:game_template/widgets/text_widget.dart';
import 'package:go_router/go_router.dart';


class BottomNavBar extends StatefulWidget {
  final Key key;
  final bool visible;

  const BottomNavBar({
    this.key = const Key("Bottom Nav bar"),
    this.visible = false,
  }): super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final ScreensController screensController = getIt<ScreensController>();
  final Map<String, IconData> bottomNavs= {
    "Play": Icons.videogame_asset,
    "Offline": Icons.signal_wifi_off,
    "Profile": Icons.person,
  };


  late VoidCallback screenListenTo;

  @override
  void initState() {
    screenListenTo = (){
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if(mounted){
          context.go(screensController.value);
        }
      });
    };
    screensController.addListener(screenListenTo);

    super.initState();
  }

  @override
  void dispose() {
    screensController.removeListener(screenListenTo) ;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: screensController,
      builder:(context, value, child) {
        if(widget.visible){
          return Container(
            color: Colors.white,
            height: 60,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ...List.generate(bottomNavs.length, (index) => Expanded(
                  child: InkWell(
                    onTap: () {
                      screensController.value = "/${bottomNavs.keys.toList()[index].toLowerCase()}";
                    },
                    child: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            bottomNavs.values.toList()[index],
                            color: screensController.value.contains(bottomNavs.keys.toList()[index].toLowerCase())
                                ? getIt<AppColor>().greenMain
                                : getIt<AppColor>().greenContrast,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: TextWidget(
                              text: bottomNavs.keys.toList()[index],
                              textSize: DefaultTextSizes.small.value,
                              textColor: screensController.value.contains(bottomNavs.keys.toList()[index].toLowerCase())
                                  ? getIt<AppColor>().greenMain
                                  : getIt<AppColor>().greenContrast,
                            ),
                          ),
                        ],
                      )
                    ),
                  ),
                ))
              ],
            ),
          );
        }else{
          return Container();
        }
      },
    );

  }
}
