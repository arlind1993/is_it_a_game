import 'dart:collection';

import 'package:game_template/screens/games/chess/chess_logic.dart';

class ChessLocation extends LinkedListEntry<ChessLocation> implements Comparable{
  int rank;
  int file;
  bool get inside => (rank >= 1 && rank <= ChessBoardState.SQUARE) && (file >= 1 && file <= ChessBoardState.SQUARE);
  String get nameConvention => inside ? String.fromCharCode(96 + file) + rank.toString() : "outside";

  ChessLocation({
    required this.rank,
    required this.file,
  });

  @override
  int compareTo(other) {
    if(!inside){
      throw "outside compare to";
    }
    if(other is ChessLocation) {
      return (ChessBoardState.SQUARE - rank) * ChessBoardState.SQUARE + (file) -
          (ChessBoardState.SQUARE - other.rank) * ChessBoardState.SQUARE + (other.file);
    }
    throw "Non Location type error";
  }

  bool operator ==(Object other) => this.compareTo(other) == 0;
  bool operator >(Object other) => this.compareTo(other) > 0;
  bool operator >=(Object other) => this.compareTo(other) >= 0;
  bool operator <(Object other) => this.compareTo(other) < 0;
  bool operator <=(Object other) => this.compareTo(other) <= 0;

  @override
  int get hashCode => super.hashCode;

  @override
  String toString() {
    return nameConvention;
  }
}

enum ChessPieceType{
  Pawn,
  Bishop,
  Knight,
  Rook,
  Queen,
  King,
}

class ChessPiece{
  bool isWhite;
  bool eaten;
  ChessLocation location;
  ChessPieceType pieceType;

  String get pieceCode {
    switch(pieceType){
      case ChessPieceType.Pawn: return "p";
      case ChessPieceType.Bishop: return "b";
      case ChessPieceType.Knight: return "n";
      case ChessPieceType.Rook: return "r";
      case ChessPieceType.Queen: return "q";
      case ChessPieceType.King: return "k";
    }
  }

  String get pieceCodeColor => isWhite ? pieceCode.toUpperCase() : pieceCode;

  ChessPiece({
    required this.location,
    required this.isWhite,
    required this.pieceType,
    this.eaten = false,
  });

  @override
  String toString() {
    // TODO: implement toString
    return "CP{type: $pieceCodeColor, location: $location}";
  }

}

// class Movement{
//
// }