import 'package:flutter/material.dart';
import 'package:game_template/widgets/text_widget.dart';
import 'package:go_router/go_router.dart';

class MainChessScreen extends StatelessWidget {
  const MainChessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextWidget(
              text: "Chess",
            ),
            TextButton(
              onPressed: () {
                context.go("/game_selector/chess/play");
              },
              child: TextWidget(
                text: "Play",
              )
            )
          ],
        ),
      ),
    );
  }
}
