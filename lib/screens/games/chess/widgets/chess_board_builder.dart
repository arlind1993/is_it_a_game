import 'package:flutter/material.dart';
import 'package:game_template/screens/games/chess/logic/chess_an_logic.dart';
import 'package:game_template/screens/games/chess/models/chess_movement.dart';
import 'package:game_template/services/extensions/iterable_extensions.dart';
import 'package:logging/logging.dart';
import '../models/chess_constants.dart';
import '../logic/chess_fen_logic.dart';
import '../models/chess_location.dart';
import '../models/chess_board_state.dart';
import '../logic/chess_possible_move_logic.dart';
import '../models/chess_piece.dart';
import '../models/chess_possible_move_group.dart';
import 'chess_promotion_popup.dart';

class ChessBoardBuilder extends StatefulWidget {
  ChessBoardState previousChessState;
  final bool youAreWhite;
  ChessBoardBuilder({
    required this.youAreWhite,
    String importFen = ChessFenAlgorithms.defaultStartingFen,
    super.key,
  }): previousChessState = ChessFenAlgorithms().fenToBoard(importFen);

  @override
  State<ChessBoardBuilder> createState() => _ChessBoardBuilderState();
}

class _ChessBoardBuilderState extends State<ChessBoardBuilder> {
  Logger _logger = Logger("Chess board builder");
  late bool _startedEmpty;
  late ValueNotifier<ChessPiece?> actualPieceSelected;
  late ValueNotifier<MapEntry<ChessPiece,Offset>?> actualPieceOffset;
  late ValueNotifier<ChessBoardState> actualChessBoard;
  late ValueNotifier<PossibleMoveGroup?> pawnPromotion;
  @override
  void initState() {
    actualPieceSelected = ValueNotifier(null);
    actualPieceOffset = ValueNotifier(null);
    actualChessBoard = ValueNotifier(widget.previousChessState);
    pawnPromotion = ValueNotifier(null);

    actualChessBoard.addListener(() {// When a move gets played
      // try{
        //_logger.warning("\n"+widget.previousChessState.toGridVisual());
        _logger.info("\n"+actualChessBoard.value.toGridVisual());
        String move = ChessANAlgorithms().parseGameStatesToAN(
            widget.previousChessState,
            actualChessBoard.value
        );
        _logger.warning(move);
      // }catch(e){
      //   print(e);
      // }
      widget.previousChessState = actualChessBoard.value;
    });

    pawnPromotion.addListener(() {
      if(pawnPromotion.value != null){
        actualChessBoard.value = actualChessBoard.value.getNewBoardFromMove(pawnPromotion.value!);
        pawnPromotion.value = null;
      }
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
              onPointerDown: (event) => onPress(event, constraint),
              onPointerUp: (event) => onRelease(event, constraint),
              onPointerMove: (event) => onDrag(event, constraint),
              child: Stack(
                children: [
                  ValueListenableBuilder(//Actual Highlighted Piece
                    valueListenable: actualPieceSelected,
                    builder: (context, value, child){
                      //_logger.warning(value);
                      if(value==null) return Container();
                      return Positioned(
                        bottom: (value.location.rank - 1) * constraint.maxWidth / ChessConstants().CHESS_SIZE_SQUARE,
                        left: (value.location.file - 1) * constraint.maxWidth / ChessConstants().CHESS_SIZE_SQUARE,
                        child: Container(
                          width: constraint.maxWidth / ChessConstants().CHESS_SIZE_SQUARE,
                          height: constraint.maxWidth / ChessConstants().CHESS_SIZE_SQUARE,
                          color: Color(0x98aad501),
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
                        List<PossibleMoveGroup> possibleMoves = ChessPossibleMovesAlgorithms().getPossibleMovesForPiece(value, actualChessBoard.value);
                        return Positioned.fill(
                          child: Stack(
                            children: [
                              ...possibleMoves.map((e){
                                if(e.eatenPiece == null){
                                  return Positioned(
                                    bottom: (e.pieceMovement.to.location.rank - 1) * constraint.maxWidth / ChessConstants().CHESS_SIZE_SQUARE,
                                    left: (e.pieceMovement.to.location.file - 1) * constraint.maxWidth / ChessConstants().CHESS_SIZE_SQUARE,
                                    child: Container(
                                      width: constraint.maxWidth / ChessConstants().CHESS_SIZE_SQUARE,
                                      height: constraint.maxWidth / ChessConstants().CHESS_SIZE_SQUARE,
                                      alignment: Alignment.center,
                                      child: Container(
                                        width: constraint.maxWidth / ChessConstants().CHESS_SIZE_SQUARE / 2,
                                        height: constraint.maxWidth / ChessConstants().CHESS_SIZE_SQUARE / 2,
                                        decoration: BoxDecoration(
                                          color: Color(0x88888888),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  );
                                }else{
                                  return Positioned(
                                    bottom: (e.pieceMovement.to.location.rank - 1) * constraint.maxWidth / ChessConstants().CHESS_SIZE_SQUARE,
                                    left: (e.pieceMovement.to.location.file - 1) * constraint.maxWidth / ChessConstants().CHESS_SIZE_SQUARE,
                                    child: Container(
                                      width: constraint.maxWidth / ChessConstants().CHESS_SIZE_SQUARE,
                                      height: constraint.maxWidth / ChessConstants().CHESS_SIZE_SQUARE,
                                      alignment: Alignment.center,
                                      child: Container(
                                        width: constraint.maxWidth / ChessConstants().CHESS_SIZE_SQUARE / 2,
                                        height: constraint.maxWidth / ChessConstants().CHESS_SIZE_SQUARE / 2,
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
                  ...actualChessBoard.value.gamePiecesMapped.values.map((e) {
                    return ValueListenableBuilder(
                      valueListenable: actualPieceOffset,
                      builder: (context, value, child) {
                        if(actualPieceSelected.value == null || actualPieceSelected.value != e || value == null){
                          return Positioned(
                            bottom: (e.location.rank - 1) * constraint.maxWidth / ChessConstants().CHESS_SIZE_SQUARE,
                            left: (e.location.file - 1) * constraint.maxWidth / ChessConstants().CHESS_SIZE_SQUARE,
                            child: Container(
                              width: constraint.maxWidth / ChessConstants().CHESS_SIZE_SQUARE,
                              height: constraint.maxWidth / ChessConstants().CHESS_SIZE_SQUARE,
                              child: ChessConstants().chessPiecePictures[e.pieceCodeColor]!,
                            ),
                          );
                        }
                        return Positioned(
                          top: value.value.dy - constraint.maxWidth / ChessConstants().CHESS_SIZE_SQUARE / 2,
                          left: value.value.dx - constraint.maxWidth / ChessConstants().CHESS_SIZE_SQUARE / 2,
                          child: Opacity(
                            opacity: 0.9,
                            child: Container(
                              width: constraint.maxWidth / ChessConstants().CHESS_SIZE_SQUARE,
                              height: constraint.maxWidth / ChessConstants().CHESS_SIZE_SQUARE,
                              child: ChessConstants().chessPiecePictures[e.pieceCodeColor]!,
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

  void onPress(PointerDownEvent event, BoxConstraints constraint){
    _logger.info("onPress: ${event.localPosition}");
    _startedEmpty = true;
    ChessLocation? location = _listenerToLocation(event.localPosition, constraint.maxWidth);
    if(location != null) {// inside Board
      ChessPiece? currPiece = actualChessBoard.value.aliveGamePiecesMapped[location];
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
          List<PossibleMoveGroup> possibleMoves = ChessPossibleMovesAlgorithms().getPossibleMovesForPiece(
              actualPieceSelected.value!, actualChessBoard.value);
          PossibleMoveGroup? possibleMoveGroup = possibleMoves.firstWhereIfThere((e) => e.pieceMovement.to.location == location);
          if(possibleMoveGroup !=null){
            if(actualPieceSelected.value!.pieceType == ChessPieceType.Pawn && (
              (actualPieceSelected.value!.isWhite && possibleMoveGroup.pieceMovement.to.location.rank == ChessConstants().CHESS_SIZE_SQUARE)
              || (!actualPieceSelected.value!.isWhite && possibleMoveGroup.pieceMovement.to.location.rank == 1)
            )){
              showDialog(
                context: context,
                useSafeArea: true,
                builder: (context) {
                  return ChessPromotionPopUp(possibleMoveGroup, pawnPromotion);
                }
              );
            }else{
              actualChessBoard.value = actualChessBoard.value.getNewBoardFromMove(possibleMoveGroup);
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
  }
  void onRelease(PointerUpEvent event, BoxConstraints constraint){
    //_logger.info("onRelease: ${event.localPosition}");
    if(actualPieceSelected.value != null){
      ChessLocation? locationTo = _listenerToLocation(event.localPosition, constraint.maxWidth);

      if (locationTo != null && actualPieceSelected.value!.isWhite == actualChessBoard.value.isWhiteTurn) {
        List<PossibleMoveGroup> possibleMoves = ChessPossibleMovesAlgorithms().getPossibleMovesForPiece(
            actualPieceSelected.value!, actualChessBoard.value);
        PossibleMoveGroup? possibleMoveGroup = possibleMoves.firstWhereIfThere((e) => e.pieceMovement.to.location == locationTo);
        if(possibleMoveGroup !=null){
          if(actualPieceSelected.value!.pieceType == ChessPieceType.Pawn && (
              (actualPieceSelected.value!.isWhite && possibleMoveGroup.pieceMovement.to.location.rank == ChessConstants().CHESS_SIZE_SQUARE)
              || (!actualPieceSelected.value!.isWhite && possibleMoveGroup.pieceMovement.to.location.rank == 1)
          )){
            showDialog(
              context: context,
              useSafeArea: true,
              builder: (context) {
                return ChessPromotionPopUp(possibleMoveGroup, pawnPromotion);
              }
            );
          }else{
            actualChessBoard.value = actualChessBoard.value.getNewBoardFromMove(possibleMoveGroup);
          }
        }
      }
    }
    actualPieceOffset.value = null;
  }
  void onDrag(PointerMoveEvent event, BoxConstraints constraint){
    //_logger.info("onDrag: ${event.localPosition}");
    if(!_startedEmpty){
      if(actualPieceSelected.value == null){
        ChessLocation? location = _listenerToLocation(event.localPosition, constraint.maxWidth);
        ChessPiece? currPiece = actualChessBoard.value.aliveGamePiecesMapped[location];
        if(currPiece?.isWhite == actualChessBoard.value.isWhiteTurn){
          actualPieceSelected.value = currPiece;
        }
      }
      if(actualPieceSelected.value != null){
        actualPieceOffset.value = MapEntry(actualPieceSelected.value!, event.localPosition);
      }
    }
  }

  ChessLocation? _listenerToLocation(Offset pos, boardSize){
    //print(boardSize);
    if(pos.dx < 0 || pos.dx > boardSize || pos.dy < 0 || pos.dy > boardSize){
      return null;
    }
    int rank = ChessConstants().CHESS_SIZE_SQUARE - pos.dy ~/ (boardSize / ChessConstants().CHESS_SIZE_SQUARE);
    int file = 1 + pos.dx ~/ (boardSize / ChessConstants().CHESS_SIZE_SQUARE);
    return ChessLocation(rank: rank, file: file);
  }
}