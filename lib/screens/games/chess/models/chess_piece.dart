import 'chess_board_state.dart';
import 'chess_constants.dart';
import 'chess_location.dart';
import 'chess_possible_move_group.dart';
///LOWKEY DONE
class ChessPiece{
  bool isWhite;
  bool eaten;
  ChessLocation location;
  ChessPieceType pieceType;

  String get pieceCode {
    switch(pieceType){
      case ChessPieceType.Pawn:   return "p";
      case ChessPieceType.Bishop: return "b";
      case ChessPieceType.Knight: return "n";
      case ChessPieceType.Rook:   return "r";
      case ChessPieceType.Queen:  return "q";
      case ChessPieceType.King:   return "k";
    }
  }

  String get pieceCodeColor => isWhite ? pieceCode.toUpperCase() : pieceCode;

  ChessPiece({
    required this.location,
    required this.isWhite,
    required this.pieceType,
    this.eaten = false,
  });

  ChessPiece.clone(ChessPiece chessPiece):
    this.location = chessPiece.location,
    this.isWhite = chessPiece.isWhite,
    this.eaten = chessPiece.eaten,
    this.pieceType = chessPiece.pieceType;

  @override
  String toString() {
    // TODO: implement toString
    return "CP{${eaten?"¬": ""}$pieceCodeColor$location}";
  }

  bool operator == (o) => o is ChessPiece
      && isWhite == o.isWhite
      && location == o.location
      && pieceType == o.pieceType
      && eaten == o.eaten;

  @override
  int get hashCode => Object.hash(isWhite, location, pieceType, eaten);
}
