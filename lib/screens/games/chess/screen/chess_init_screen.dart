import 'package:flutter/material.dart';
import 'package:game_template/screens/games/chess/models/chess_board_state.dart';

import '../widgets/chess_play_board.dart';

class ChessInitScreen extends StatelessWidget {
  const ChessInitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 30,),
        ChessPlayBoard(key: Key("chess board")),
        Expanded(child: Container()),
      ],
    );
  }
}
