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
    return "Move $from ==> $to";
  }
}

class NullableChessMovement{
  ChessPiece? from;
  ChessPiece? to;

  NullableChessMovement({
    this.from,
    this.to,
  });

  @override
  String toString() {
    return "Move $from ==> $to";
  }
}