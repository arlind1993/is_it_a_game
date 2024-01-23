import 'package:flutter/material.dart';
import 'package:game_template/screens/screens_controller.dart';
import 'package:game_template/services/get_it_helper.dart';
import 'package:go_router/go_router.dart';

import '../widgets/text_widget.dart';

class MainMenuScreen extends StatefulWidget {
  MainMenuScreen({super.key}){
  }

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      global.screenController.value = "/play";
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextWidget(
            text: "Main menu",
          ),
          TextButton(onPressed: () {
            global.screenController.value = "/play";

          }, child: TextWidget(text: "Redirect"))
        ],
      ),
    );
  }
}
