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

  @override
  String toString() {
    return "{movement: $pieceMovement, eat: $eatenPiece, args_kq: {${kingSide?1:0}, ${queenSide?1:0}}}";
  }

}