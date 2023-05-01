import 'package:flutter/material.dart';
import 'package:game_template/screens/games/chess/widget/chess_piece_builder.dart';
import 'package:logging/logging.dart';
import '../chess_global.dart';
import '../chess_logic.dart';
import '../chess_piece_logic.dart';

class ChessBoardBuilder extends StatefulWidget {


  ChessBoardState chessBoardState;
  ChessBoardBuilder({
    required this.chessBoardState,
    super.key
  });

  @override
  State<ChessBoardBuilder> createState() => _ChessBoardBuilderState();
}

class _ChessBoardBuilderState extends State<ChessBoardBuilder> {
  Logger _logger = Logger("Chess board builder");
  ChessPiece? actualPieceSelected;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (event) {
            if(actualPieceSelected == null){
              ChessLocation? location = _listenerToLocation(event.localPosition, constraint.maxWidth);
              if(location != null) {
                actualPieceSelected = widget.chessBoardState.aliveGamePieces.firstWhere((element) => element.location == location,orElse: () => ChessPiece(location: ChessLocation(file: 0, rank: 0), isWhite: true, pieceType: ChessPieceType.Pawn),);
              }
            }else{
              actualPieceSelected = null;
            }
            _logger.info("onPointerDown: ${event.localPosition}");
          },
          onPointerUp: (event) {
            _logger.info("onPointerUp: ${event.localPosition}");
          },
          onPointerMove: (event) {
            _logger.info("onPointerMove: ${event.localPosition}");
          },
          child: Stack(
            children: [

              ...widget.chessBoardState.aliveGamePieces.map((e) {
                return Positioned(
                  bottom: (e.location.rank - 1) * constraint.maxWidth / ChessBoardState.SQUARE,
                  left: (e.location.file - 1) * constraint.maxWidth / ChessBoardState.SQUARE,
                  child: Container(
                    width: constraint.maxWidth / ChessBoardState.SQUARE,
                    height: constraint.maxWidth / ChessBoardState.SQUARE,
                    child: chessPiecePictures[e.pieceCodeColor]!,
                  ),
                );
              }),
            ]
          ),
        );
      }
    );
  }

  ChessLocation? _listenerToLocation(Offset pos, boardSize){
    print(boardSize);
    if(pos.dx < 0 || pos.dx > boardSize || pos.dy < 0 || pos.dy > boardSize){
      return null;
    }
    int rank = ChessBoardState.SQUARE - pos.dy ~/ (boardSize / ChessBoardState.SQUARE);
    int file = 1 + pos.dx ~/ (boardSize / ChessBoardState.SQUARE);
    return ChessLocation(rank: rank, file: file);
  }
}