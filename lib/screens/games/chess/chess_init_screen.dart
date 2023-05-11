import 'package:flutter/material.dart';
import 'package:game_template/screens/games/chess/logic/chess_logic.dart';

import 'widget/chess_play_board.dart';

class ChessInitScreen extends StatelessWidget {
  const ChessInitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 30,),
        ChessPlayBoard(
          key: Key("chess board"),
          import: ChessBoardState(initFen: "r3kbnr/p1p1q3/2np1p2/Pp3bpp/1P2p3/1QPPPNPB/1B1N1P1P/R3K2R b KQkq b6 0 13")
        ),
        Expanded(
          child: Container()
        )
      ],
    );
  }
}
