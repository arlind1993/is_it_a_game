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
  late ValueNotifier<ChessPiece?> actualPieceSelected;
  late ValueNotifier<MapEntry<ChessPiece,Offset>?> actualPieceOffset;
  late ValueNotifier<ChessBoardState> actualChessBoard;
  late bool _startedEmpty;
  @override
  void initState() {
    actualPieceSelected = ValueNotifier(null);
    actualPieceSelected.addListener(() {
      _logger.info(actualPieceSelected);
    });
    actualPieceOffset = ValueNotifier(null);
    actualChessBoard = ValueNotifier(widget.chessBoardState);
    actualChessBoard.addListener(() {// When a move gets played
      print("refresh");
      setState(() {

      });
    });
    super.initState();
  }

  @override
  void dispose() {
    actualPieceSelected.dispose();
    actualPieceOffset.dispose();
    actualChessBoard.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return ValueListenableBuilder(
          valueListenable: actualChessBoard,
          builder: (context, val, child) {
            return Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (event) {
                //_logger.info("onPointerDown: ${event.localPosition}");
                _startedEmpty = true;
                ChessLocation? location = _listenerToLocation(event.localPosition, constraint.maxWidth);
                if(location != null) {// inside Board
                  ChessPiece? currPiece = Movement.getFirstAlivePieceIfInLocation(
                      actualChessBoard.value.gamePieces, location);

                  if(currPiece!=null && currPiece.isWhite == actualChessBoard.value.isWhiteTurn){// onTop of actual Piece
                    _startedEmpty = false;
                    if(actualPieceOffset.value==null) actualPieceOffset.value = MapEntry(currPiece, event.localPosition);
                    if(currPiece == actualPieceSelected.value){
                        actualPieceSelected.value = null;
                    }else{
                      actualPieceSelected.value = currPiece;
                    }
                  }else{//notOnTop of actual Piece
                    if(actualPieceSelected.value!=null){
                      List<PossibleMoveGroup> possibleMoves = Movement.getPossibleMovesForPiece(
                          actualPieceSelected.value!, actualChessBoard.value);
                      PossibleMoveGroup? possibleMoveGroup = possibleMoves.firstWhereIfThere((e) => e.location == location);
                      if(possibleMoveGroup !=null){
                        if(possibleMoveGroup.specialArgument != null){
                          if(possibleMoveGroup.specialArgument == "king_side"){
                            Movement king = Movement(
                              from: actualPieceSelected.value!,
                              to: ChessPiece.clone(actualPieceSelected.value!)..location = ChessLocation(
                                  file: actualPieceSelected.value!.location.file + 2,
                                  rank: actualPieceSelected.value!.location.rank)
                            );
                            ChessPiece? rookPiece = actualChessBoard.value.gamePieces.firstWhereIfThere((element) {
                              return element.isWhite == actualPieceSelected.value!.isWhite
                                && element.pieceType == ChessPieceType.Rook
                                && element.eaten == actualPieceSelected.value!.eaten
                                && element.location.rank == actualPieceSelected.value!.location.rank
                                && element.location.file > actualPieceSelected.value!.location.file;
                            });
                            if(rookPiece!=null){
                              Movement rook = Movement(
                                  from: rookPiece,
                                  to: ChessPiece.clone(rookPiece)..location.file = actualPieceSelected.value!.location.file + 1
                              );
                              actualChessBoard.value.setMoves([king, rook]);
                              actualChessBoard.notifyListeners();
                            }
                          }else if(possibleMoveGroup.specialArgument == "queen_side"){
                            Movement king = Movement(
                                from: actualPieceSelected.value!,
                                to: ChessPiece.clone(actualPieceSelected.value!)..location = ChessLocation(
                                    file: actualPieceSelected.value!.location.file - 2,
                                    rank: actualPieceSelected.value!.location.rank)
                            );
                            ChessPiece? rookPiece = actualChessBoard.value.gamePieces.firstWhereIfThere((element) {
                              return element.isWhite == actualPieceSelected.value!.isWhite
                                  && element.pieceType == ChessPieceType.Rook
                                  && element.eaten == actualPieceSelected.value!.eaten
                                  && element.location.rank == actualPieceSelected.value!.location.rank
                                  && element.location.file < actualPieceSelected.value!.location.file;
                            });
                            if(rookPiece != null) {
                              Movement rook = Movement(
                                from: rookPiece,
                                to: ChessPiece.clone(rookPiece)..location.file = actualPieceSelected.value!.location.file - 1
                              );
                              actualChessBoard.value.setMoves([king, rook]);
                              actualChessBoard.notifyListeners();
                            }
                          }else{
                            actualChessBoard.value.setMoves([
                              Movement(from: actualPieceSelected.value!, to: ChessPiece.clone(actualPieceSelected.value!)..location = possibleMoveGroup.location),
                              if(possibleMoveGroup.eatenPiece != null)
                                Movement(from: possibleMoveGroup.eatenPiece!, to: ChessPiece.clone(possibleMoveGroup.eatenPiece!)..eaten = true),
                            ]);
                            actualChessBoard.notifyListeners();
                          }
                        }else{
                          actualChessBoard.value.setMoves([
                            Movement(from: actualPieceSelected.value!, to: ChessPiece.clone(actualPieceSelected.value!)..location = possibleMoveGroup.location),
                            if(possibleMoveGroup.eatenPiece != null)
                              Movement(from: possibleMoveGroup.eatenPiece!, to: ChessPiece.clone(possibleMoveGroup.eatenPiece!)..eaten = true),
                          ]);
                          actualChessBoard.notifyListeners();
                        }
                      }
                    }

                    actualPieceSelected.value = null;
                    actualPieceOffset.value = null;
                  }
                }else{//outside Board
                  actualPieceSelected.value = null;
                  actualPieceOffset.value = null;
                }
              },
              onPointerUp: (event) {
                //_logger.info("onPointerUp: ${event.localPosition}");
                if(actualPieceSelected.value != null){
                  ChessLocation? locationTo = _listenerToLocation(event.localPosition, constraint.maxWidth);

                  if (locationTo != null && actualPieceSelected.value!.isWhite == actualChessBoard.value.isWhiteTurn) {
                    List<PossibleMoveGroup> possibleMoves = Movement.getPossibleMovesForPiece(
                        actualPieceSelected.value!, actualChessBoard.value);
                    PossibleMoveGroup? possibleMoveGroup = possibleMoves.firstWhereIfThere((e) => e.location == locationTo);
                    _logger.warning(possibleMoveGroup);
                    if(possibleMoveGroup !=null){
                      if(possibleMoveGroup.specialArgument != null){
                        if(possibleMoveGroup.specialArgument == "king_side"){
                          Movement king = Movement(
                              from: actualPieceSelected.value!,
                              to: ChessPiece.clone(actualPieceSelected.value!)..location = ChessLocation(
                                  file: actualPieceSelected.value!.location.file + 2,
                                  rank: actualPieceSelected.value!.location.rank)
                          );
                          ChessPiece? rookPiece = actualChessBoard.value.gamePieces.firstWhereIfThere((element) {
                            return element.isWhite == actualPieceSelected.value!.isWhite
                                && element.pieceType == ChessPieceType.Rook
                                && element.eaten == actualPieceSelected.value!.eaten
                                && element.location.rank == actualPieceSelected.value!.location.rank
                                && element.location.file > actualPieceSelected.value!.location.file;
                          });
                          if(rookPiece!=null){
                            Movement rook = Movement(
                                from: rookPiece,
                                to: ChessPiece.clone(rookPiece)..location.file = actualPieceSelected.value!.location.file + 1
                            );
                            actualChessBoard.value.setMoves([king, rook]);
                            actualChessBoard.notifyListeners();
                          }
                        }else if(possibleMoveGroup.specialArgument == "queen_side"){
                          Movement king = Movement(
                              from: actualPieceSelected.value!,
                              to: ChessPiece.clone(actualPieceSelected.value!)..location = ChessLocation(
                                  file: actualPieceSelected.value!.location.file - 2,
                                  rank: actualPieceSelected.value!.location.rank)
                          );
                          ChessPiece? rookPiece = actualChessBoard.value.gamePieces.firstWhereIfThere((element) {
                            return element.isWhite == actualPieceSelected.value!.isWhite
                                && element.pieceType == ChessPieceType.Rook
                                && element.eaten == actualPieceSelected.value!.eaten
                                && element.location.rank == actualPieceSelected.value!.location.rank
                                && element.location.file < actualPieceSelected.value!.location.file;
                          });
                          if(rookPiece != null) {
                            Movement rook = Movement(
                                from: rookPiece,
                                to: ChessPiece.clone(rookPiece)..location.file = actualPieceSelected.value!.location.file - 1
                            );
                            actualChessBoard.value.setMoves([king, rook]);
                            actualChessBoard.notifyListeners();
                          }
                        }else{
                          actualChessBoard.value.setMoves([
                            Movement(from: actualPieceSelected.value!, to: ChessPiece.clone(actualPieceSelected.value!)..location = possibleMoveGroup.location),
                            if(possibleMoveGroup.eatenPiece != null)
                              Movement(from: possibleMoveGroup.eatenPiece!, to: ChessPiece.clone(possibleMoveGroup.eatenPiece!)..eaten = true),
                          ]);
                          actualChessBoard.notifyListeners();
                        }
                      }else{
                        actualChessBoard.value.setMoves([
                          Movement(from: actualPieceSelected.value!, to: ChessPiece.clone(actualPieceSelected.value!)..location = possibleMoveGroup.location),
                          if(possibleMoveGroup.eatenPiece != null)
                            Movement(from: possibleMoveGroup.eatenPiece!, to: ChessPiece.clone(possibleMoveGroup.eatenPiece!)..eaten = true),
                        ]);
                        actualChessBoard.notifyListeners();
                      }
                    }
                  }
                }
                actualPieceOffset.value = null;
              },
              onPointerMove: (event) {
                //_logger.info("onPointerMove: ${event.localPosition}");
                if(!_startedEmpty){
                  if(actualPieceSelected.value == null){
                    ChessLocation? location = _listenerToLocation(event.localPosition, constraint.maxWidth);
                    ChessPiece? currPiece = Movement.getFirstAlivePieceIfInLocation(actualChessBoard.value.gamePieces, location);
                    if(currPiece?.isWhite == actualChessBoard.value.isWhiteTurn){
                      actualPieceSelected.value = currPiece;
                    }
                  }

                  if(actualPieceSelected.value != null){
                    actualPieceOffset.value = MapEntry(actualPieceSelected.value!, event.localPosition);
                  }
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
                        List<PossibleMoveGroup> possibleMoves
                          = Movement.getPossibleMovesForPiece(value, actualChessBoard.value);
                        return Positioned.fill(
                          child: Stack(
                            children: [
                              ...possibleMoves.map((e){
                                if(e.eatenPiece == null){
                                  return Positioned(
                                    bottom: (e.location.rank - 1) * constraint.maxWidth / ChessBoardState.SQUARE,
                                    left: (e.location.file - 1) * constraint.maxWidth / ChessBoardState.SQUARE,
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
                                    bottom: (e.location.rank - 1) * constraint.maxWidth / ChessBoardState.SQUARE,
                                    left: (e.location.file - 1) * constraint.maxWidth / ChessBoardState.SQUARE,
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
                  ...actualChessBoard.value.aliveGamePieces.map((e) {
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