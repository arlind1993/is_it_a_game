
import 'package:flutter/material.dart';
import 'package:game_template/screens/games/chess/chess_piece_logic.dart';
import 'package:logging/logging.dart';

import '../chess_global.dart';
import '../chess_logic.dart';


Logger _logger = Logger("Chess Piece Builder");
class ChessPieceBuilder extends StatefulWidget{
  ChessPiece currPiece;
  ChessBoardState chessBoardState;
  ChessPieceBuilder({
    super.key,
    required this.currPiece,
    required this.chessBoardState,
  });

  @override
  State<ChessPieceBuilder> createState() => _ChessPieceBuilderState();
}

class _ChessPieceBuilderState extends State<ChessPieceBuilder>{
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return Container(
          width: constraint.maxWidth / ChessBoardState.SQUARE,
          height: constraint.maxWidth / ChessBoardState.SQUARE,
          child: chessPiecePictures[widget.currPiece.pieceCodeColor]!,
        );
      }
    );
  }

}
