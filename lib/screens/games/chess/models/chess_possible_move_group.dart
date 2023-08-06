// import 'dart:collection';
//
// import 'package:game_template/services/extensions/iterable_extensions.dart';
//
// import 'sudoku_board_state.dart';
// import 'sudoku_constants.dart';
// import 'chess_location.dart';
import 'chess_movement.dart';
import 'chess_piece.dart';

class PossibleMoveGroup{
  ChessMovement pieceMovement;
  ChessPiece? eatenPiece;
  bool kingSide;
  bool queenSide;

  bool get changeMade => kingSide || queenSide || eatenPiece != null || pieceMovement.from != pieceMovement.to;

  PossibleMoveGroup({
    required this.pieceMovement,
    this.eatenPiece,
    this.kingSide = false,
    this.queenSide = false,
  });

  PossibleMoveGroup.clone(PossibleMoveGroup possibleMoveGroup) :
    pieceMovement = ChessMovement.clone(possibleMoveGroup.pieceMovement),
    eatenPiece = possibleMoveGroup.eatenPiece == null ? null : ChessPiece.clone(possibleMoveGroup.eatenPiece!),
    kingSide = possibleMoveGroup.kingSide,
    queenSide = possibleMoveGroup.queenSide;

  @override
  String toString() {
    return "{movement: $pieceMovement, eat: $eatenPiece, args_kq: {${kingSide?1:0}, ${queenSide?1:0}}}";
  }




  @override
  bool operator ==(Object other) {
    return other is PossibleMoveGroup
      && pieceMovement == other.pieceMovement
      && eatenPiece == other.eatenPiece
      && kingSide == other.kingSide
      && queenSide == other.queenSide;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => Object.hash(pieceMovement, eatenPiece, kingSide, queenSide);
}