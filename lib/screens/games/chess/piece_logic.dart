class PieceLogic{
  bool isWhiteTurn = true;
  bool inCheckWhite = false;
  bool inCheckBlack = false;
  bool blackQueenSide = true;
  bool blackKingSide = true;
  bool whiteQueenSide = true;
  bool whiteKingSide = true;
  Piece? lastEnPassantMove;
}


class Piece{
  bool isWhite;
  bool eaten;
  int rank;
  int file;
  String get nameConvention => (rank >= 1 && rank <= 8) && (file >= 1 && file <= 8) ? String.fromCharCode(96 + file) + rank.toString() : "eaten";
  Piece({
    required this.rank,
    required this.file,
    required this.isWhite,
    this.eaten = false,
  });
}

class Pawn extends Piece{
  int doubleMoveAllowed;
  Pawn({
    required super.rank,
    required super.file,
    required super.isWhite,
    super.eaten = false,
  }): doubleMoveAllowed = isWhite ? 2 : 7;
}