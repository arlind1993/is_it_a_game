import 'package:flutter/material.dart';
import 'package:game_template/screens/games/chess/chess_play_board.dart';

class ChessPlayScreen extends StatelessWidget {
  const ChessPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ChessPlayBoard(key: Key("chess board")),
        Expanded(
          child: Container()
        )
      ],
    );
  }
}
