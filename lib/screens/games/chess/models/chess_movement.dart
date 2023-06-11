import 'chess_piece.dart';

class ChessMovement{
  ChessPiece from;
  ChessPiece to;

  ChessMovement({
    required this.from,
    required this.to,
  });

  ChessMovement.clone(ChessMovement chessMovement) :
    from = ChessPiece.clone(chessMovement.from),
    to = ChessPiece.clone(chessMovement.to);


  @override
  String toString() {
    return "Move $from ==> $to";
  }

  @override
  bool operator ==(Object other) {
    return other is ChessMovement && from == other.from && to == other.to;
  }

  @override
  int get hashCode => Object.hash(from, to);
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
    return "Move ${from ?? "■"} ==> ${to ?? "■"}";
  }

  @override
  bool operator ==(Object other) {
    return other is NullableChessMovement && from == other.from && to == other.to;
  }

  @override
  int get hashCode => Object.hash(from, to);
}