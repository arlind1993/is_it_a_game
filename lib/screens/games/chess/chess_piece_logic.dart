import 'dart:collection';

import 'package:game_template/screens/games/chess/chess_logic.dart';
import 'package:logging/logging.dart';

class ChessLocation extends LinkedListEntry<ChessLocation> implements Comparable{
  late int rank;
  late int file;
  bool get inside => (rank >= 1 && rank <= ChessBoardState.SQUARE) && (file >= 1 && file <= ChessBoardState.SQUARE);
  String get nameConvention => inside ? String.fromCharCode(96 + file) + rank.toString() : "outside";

  ChessLocation({
    required this.rank,
    required this.file,
  });

  ChessLocation.fromChessNotation(String notation){
    String fileIntString = "";
    String rankIntString = "";
    for(int character in notation.toLowerCase().runes){
      if(character >= 48 && character < 58){
        rankIntString += String.fromCharCode(character - 48);
      }else if(character >= 97 && character < 123){
        fileIntString += String.fromCharCode(character - 96);
      }
    }
    file = int.parse(fileIntString);
    rank = int.parse(rankIntString);
  }

  @override
  int compareTo(other) {
    if(!inside){
      throw "outside compare to";
    }
    if(other is ChessLocation) {
      return ((ChessBoardState.SQUARE - rank) * ChessBoardState.SQUARE + (file))-
          ((ChessBoardState.SQUARE - other.rank) * ChessBoardState.SQUARE + (other.file));
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

  bool operator == (o) => o is ChessPiece
      && isWhite == o.isWhite
      && location == o.location
      && pieceType == o.pieceType
      && eaten == o.eaten;

  @override
  int get hashCode => super.hashCode;
}

class Movement{
  static Logger _logger = Logger("Movement");
  static bool isInCheck(bool isWhite){
    return false;
  }

  static List<ChessLocation> getPossibleMovesForPiece(ChessPiece chessPiece, ChessBoardState gameState){

    if(gameState.isWhiteTurn && chessPiece.isWhite){//movesForWhite
      _logger.fine("Moves only for white");
      switch(chessPiece.pieceType){
        case ChessPieceType.Pawn:
          print(gameState);
          List<ChessLocation> pawnLocations= [];
          if(gameState.lastEnPassantMove!=null){//en passant move
            if(chessPiece.location.rank == gameState.lastEnPassantMove!.rank
                && (chessPiece.location.file - gameState.lastEnPassantMove!.file).abs() == 1
            ){
              pawnLocations.add(
                ChessLocation(
                  rank: chessPiece.location.rank + 1,
                  file: gameState.lastEnPassantMove!.file
                )
              );//enPassantMove if possible added
            }
          }else{
            pawnLocations.addAll([
            ...gameState.gamePieces.where((element){
                return !element.eaten && !element.isWhite
                  && (chessPiece.location.file - element.location.file).abs() == 1
                  && chessPiece.location.rank + 1 == element.location.rank;
              }).map((e) => e.location).toList()
            ]);//the two adjacent pawns if there

            //add forwardMove if not blocked;
            bool firstMovePossible = !gameState.gamePieces.any((element) {
              return !element.eaten && !element.isWhite
                  && chessPiece.location.rank + 1 == element.location.rank;
            });
            bool secondMovePossible = chessPiece.location.rank == 2 && !gameState.gamePieces.any((element) {
              return !element.eaten && !element.isWhite
                  && chessPiece.location.rank + 2 == element.location.rank;
            });

            if(secondMovePossible){
              pawnLocations.add(ChessLocation(rank: chessPiece.location.rank + 1, file: chessPiece.location.file));
              pawnLocations.add(ChessLocation(rank: chessPiece.location.rank + 2, file: chessPiece.location.file));
            }else if(firstMovePossible){
              pawnLocations.add(ChessLocation(rank: chessPiece.location.rank + 1, file: chessPiece.location.file));
            }
          }
          return pawnLocations.where((element) => element.inside).toList();
        case ChessPieceType.Bishop:
          break;
        case ChessPieceType.Knight:
          List<ChessLocation> knightLocations = [];

          knightLocations.addAll([
            ChessLocation(rank: chessPiece.location.rank + 1, file: chessPiece.location.file + 2),
            ChessLocation(rank: chessPiece.location.rank + 1, file: chessPiece.location.file - 2),
            ChessLocation(rank: chessPiece.location.rank - 1, file: chessPiece.location.file + 2),
            ChessLocation(rank: chessPiece.location.rank - 1, file: chessPiece.location.file - 2),
            ChessLocation(rank: chessPiece.location.rank + 2, file: chessPiece.location.file + 1),
            ChessLocation(rank: chessPiece.location.rank + 2, file: chessPiece.location.file - 1),
            ChessLocation(rank: chessPiece.location.rank - 2, file: chessPiece.location.file + 1),
            ChessLocation(rank: chessPiece.location.rank - 2, file: chessPiece.location.file - 1),
          ].where((element) {//blocked by own pieces;
            return !gameState.gamePieces.where((element) {
              return !element.eaten && element.isWhite;
            }).map((e) => e.location).contains(element);
          }));

          return knightLocations.where((element) => element.inside).toList();
          break;
        case ChessPieceType.Rook:
        // TODO: Handle this case.
          break;
        case ChessPieceType.Queen:
        // TODO: Handle this case.
          break;
        case ChessPieceType.King:
        // TODO: Handle this case.
          break;
      }
    }else if(!gameState.isWhiteTurn && !chessPiece.isWhite){//Moves for black
      _logger.fine("Moves only for black");
      switch(chessPiece.pieceType){
        case ChessPieceType.Pawn:
          break;
        case ChessPieceType.Bishop:
          break;
        case ChessPieceType.Knight:
        // TODO: Handle this case.
          break;
        case ChessPieceType.Rook:
        // TODO: Handle this case.
          break;
        case ChessPieceType.Queen:
        // TODO: Handle this case.
          break;
        case ChessPieceType.King:
        // TODO: Handle this case.
          break;
      }
    }

    return [];
  }


}