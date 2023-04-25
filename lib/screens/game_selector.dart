import 'package:flutter/material.dart';

import '../widgets/text_widget.dart';

class GameSelector extends StatelessWidget {
  const GameSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextWidget(
          text: "Game Select",
        ),
      ),
    );
  }
}
