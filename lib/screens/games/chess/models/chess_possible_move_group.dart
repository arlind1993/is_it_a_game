import 'chess_movement.dart';
import 'chess_piece.dart';

class PossibleMoveGroup{
  ChessMovement pieceMovement;
  ChessPiece? eatenPiece;
  bool kingSide;
  bool queenSide;
  bool enPassant;

  bool get changeMade => kingSide || queenSide || enPassant || eatenPiece != null || pieceMovement.from != pieceMovement.to;

  PossibleMoveGroup({
    required this.pieceMovement,
    this.eatenPiece,
    this.kingSide = false,
    this.queenSide = false,
    this.enPassant = false,
  });

  @override
  String toString() {
    return "{movement: $pieceMovement, eatPiece: $eatenPiece, args_kqe: {${kingSide?1:0}, ${queenSide?1:0}, ${enPassant?1:0}}}";
  }

}