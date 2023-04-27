import 'dart:collection';

class Location extends LinkedListEntry<Location>{
  int rank;
  int file;
  bool get inside => (rank >= 1 && rank <= 8) && (file >= 1 && file <= 8);
  String get nameConvention => inside ? String.fromCharCode(96 + file) + rank.toString() : "outside";

  Location({
    required this.rank,
    required this.file,
  });
}

class Piece{
  bool isWhite;
  bool eaten;
  Location location;
  Piece({
    required this.location,
    required this.isWhite,
    this.eaten = false,
  });


}

class Rook extends Piece{
  int doubleMoveAllowed;
  List<LinkedList<Location>> get pieceBySelfAllMoves {
    List<LinkedList<Location>> res = [];
    return res;
  }
  Rook({
    required super.location,
    required super.isWhite,
    super.eaten = false,
  }): doubleMoveAllowed = isWhite ? 2 : 7;

}

class Bishop extends Piece{
  int doubleMoveAllowed;
  List<LinkedList<Location>> get pieceBySelfAllMoves {
    List<LinkedList<Location>> res = [];
    return res;
  }
  Bishop({
    required super.location,
    required super.isWhite,
    super.eaten = false,
  }): doubleMoveAllowed = isWhite ? 2 : 7;

}
class Knight extends Piece{
  int doubleMoveAllowed;
  List<LinkedList<Location>> get pieceBySelfAllMoves {
    List<LinkedList<Location>> res = [];
    return res;
  }
  Knight({
    required super.location,
    required super.isWhite,
    super.eaten = false,
  }): doubleMoveAllowed = isWhite ? 2 : 7;

}
class King extends Piece{
  int doubleMoveAllowed;
  List<LinkedList<Location>> get pieceBySelfAllMoves {
    List<LinkedList<Location>> res = [];
    return res;
  }
  King({
    required super.location,
    required super.isWhite,
    super.eaten = false,
  }): doubleMoveAllowed = isWhite ? 2 : 7;

}
class Queen extends Piece{
  int doubleMoveAllowed;
  List<LinkedList<Location>> get pieceBySelfAllMoves {
    List<LinkedList<Location>> res = [];
    return res;
  }
  Queen({
    required super.location,
    required super.isWhite,
    super.eaten = false,
  }): doubleMoveAllowed = isWhite ? 2 : 7;

}
class Pawn extends Piece{
  int doubleMoveAllowed;
  List<LinkedList<Location>> get pieceBySelfAllMoves {
    List<LinkedList<Location>> res = [];
    return res;
  }
  Pawn({
    required super.location,
    required super.isWhite,
    super.eaten = false,
  }): doubleMoveAllowed = isWhite ? 2 : 7;

}