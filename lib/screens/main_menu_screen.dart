import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/text_widget.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextWidget(
              text: "Main menu",
            ),
            TextButton(onPressed: () {
              context.go("/game_selector/chess");
            }, child: TextWidget(text: "Redirect"))
          ],
        ),
      ),
    );
  }
}
