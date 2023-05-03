import 'package:flutter/material.dart';
import 'package:game_template/services/extensions/iterable_extensions.dart';
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
  ValueNotifier<ChessPiece?> actualPieceSelected = ValueNotifier(null);
  ValueNotifier<MapEntry<ChessPiece,Offset>?> actualPieceOffset = ValueNotifier(null);
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (event) {
            //_logger.info("onPointerDown: ${event.localPosition}");

            ChessLocation? location = _listenerToLocation(event.localPosition, constraint.maxWidth);
            if(location != null) {// outside Board
              ChessPiece? currPiece = Movement.getFirstAlivePieceIfInLocation(
                  widget.chessBoardState.gamePieces, location);

              if(currPiece!=null){// onTop of actual Piece
                if(actualPieceOffset.value==null) actualPieceOffset.value = MapEntry(currPiece, event.localPosition);
                if(currPiece == actualPieceSelected.value){
                    actualPieceSelected.value = null;
                }else{
                  actualPieceSelected.value = currPiece;
                }
              }else{
                actualPieceSelected.value = null;
                actualPieceOffset.value = null;
              }
            }else{//notOnTop of actual Piece
              actualPieceSelected.value = null;
              actualPieceOffset.value = null;
            }
          },
          onPointerUp: (event) {
            //_logger.info("onPointerUp: ${event.localPosition}");
            if(actualPieceOffset.value != null){

            }
            actualPieceOffset.value = null;
          },
          onPointerMove: (event) {
            //_logger.info("onPointerMove: ${event.localPosition}");
            if(actualPieceSelected.value == null){
              ChessLocation? location = _listenerToLocation(event.localPosition, constraint.maxWidth);
              ChessPiece? currPiece = Movement.getFirstAlivePieceIfInLocation(widget.chessBoardState.gamePieces, location);
              actualPieceSelected.value = currPiece;
            }

            if(actualPieceSelected.value != null){
              actualPieceOffset.value = MapEntry(actualPieceSelected.value!, event.localPosition);
            }
          },
          child: Stack(
            children: [
              ValueListenableBuilder(//Actual Highlighted Piece
                valueListenable: actualPieceSelected,
                builder: (context, value, child){
                  //_logger.warning(value);
                  if(value==null){
                    return Container();
                  }
                  return Positioned(
                    bottom: (value.location.rank - 1) * constraint.maxWidth / ChessBoardState.SQUARE,
                    left: (value.location.file - 1) * constraint.maxWidth / ChessBoardState.SQUARE,
                    child: Container(
                      width: constraint.maxWidth / ChessBoardState.SQUARE,
                      height: constraint.maxWidth / ChessBoardState.SQUARE,
                      color: Color(0xb8aad501),
                    ),
                  );
                }
              ),
              ValueListenableBuilder(// Possible Moves
                  valueListenable: actualPieceSelected,
                  builder: (context, value, child){
                    if(value==null){
                      return Container();
                    }
                    List<MapEntry<ChessLocation, ChessPiece?>> possibleMoves
                      = Movement.getPossibleMovesForPiece(value, widget.chessBoardState);
                    return Positioned.fill(
                      child: Stack(
                        children: [
                          ...possibleMoves.map((e){
                            if(e.value == null){
                              return Positioned(
                                bottom: (e.key.rank - 1) * constraint.maxWidth / ChessBoardState.SQUARE,
                                left: (e.key.file - 1) * constraint.maxWidth / ChessBoardState.SQUARE,
                                child: Container(
                                  width: constraint.maxWidth / ChessBoardState.SQUARE,
                                  height: constraint.maxWidth / ChessBoardState.SQUARE,
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: constraint.maxWidth / ChessBoardState.SQUARE / 2,
                                    height: constraint.maxWidth / ChessBoardState.SQUARE / 2,
                                    decoration: BoxDecoration(
                                      color: Color(0x88888888),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              );
                            }else{
                              return Positioned(
                                bottom: (e.key.rank - 1) * constraint.maxWidth / ChessBoardState.SQUARE,
                                left: (e.key.file - 1) * constraint.maxWidth / ChessBoardState.SQUARE,
                                child: Container(
                                  width: constraint.maxWidth / ChessBoardState.SQUARE,
                                  height: constraint.maxWidth / ChessBoardState.SQUARE,
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: constraint.maxWidth / ChessBoardState.SQUARE / 2,
                                    height: constraint.maxWidth / ChessBoardState.SQUARE / 2,
                                    decoration: BoxDecoration(
                                      color: Color(0x88D06800),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              );
                            }
                          }),
                        ],
                      ),
                    );
                  }
              ),
              ...widget.chessBoardState.aliveGamePieces.map((e) {
                return ValueListenableBuilder(
                  valueListenable: actualPieceOffset,
                  builder: (context, value, child) {
                    if(actualPieceSelected.value == null || actualPieceSelected.value != e || value == null){
                      return Positioned(
                        bottom: (e.location.rank - 1) * constraint.maxWidth / ChessBoardState.SQUARE,
                        left: (e.location.file - 1) * constraint.maxWidth / ChessBoardState.SQUARE,
                        child: Container(
                          width: constraint.maxWidth / ChessBoardState.SQUARE,
                          height: constraint.maxWidth / ChessBoardState.SQUARE,
                          child: chessPiecePictures[e.pieceCodeColor]!,
                        ),
                      );
                    }
                    return Positioned(
                      top: value.value.dy - constraint.maxWidth / ChessBoardState.SQUARE / 2,
                      left: value.value.dx - constraint.maxWidth / ChessBoardState.SQUARE / 2,
                      child: Opacity(
                        opacity: 0.9,
                        child: Container(
                          width: constraint.maxWidth / ChessBoardState.SQUARE,
                          height: constraint.maxWidth / ChessBoardState.SQUARE,
                          child: chessPiecePictures[e.pieceCodeColor]!,
                        ),
                      ),
                    );
                  },
                );
              }),
            ]
          ),
        );
      }
    );
  }

  ChessLocation? _listenerToLocation(Offset pos, boardSize){
    //print(boardSize);
    if(pos.dx < 0 || pos.dx > boardSize || pos.dy < 0 || pos.dy > boardSize){
      return null;
    }
    int rank = ChessBoardState.SQUARE - pos.dy ~/ (boardSize / ChessBoardState.SQUARE);
    int file = 1 + pos.dx ~/ (boardSize / ChessBoardState.SQUARE);
    return ChessLocation(rank: rank, file: file);
  }
}