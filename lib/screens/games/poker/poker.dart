import 'package:flutter/material.dart';

import '../../../widgets/text_widget.dart';

class MainPokerScreen extends StatelessWidget {
  const MainPokerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextWidget(
          text: "Poker",
        ),
      ),
    );
  }
}
