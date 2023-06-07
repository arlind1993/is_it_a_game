import 'chess_piece.dart';

class ChessMovement{
  ChessPiece from;
  ChessPiece to;

  ChessMovement({
    required this.from,
    required this.to,
  });

  @override
  String toString() {
    return "From_:$from .... To_:$to";
  }
}