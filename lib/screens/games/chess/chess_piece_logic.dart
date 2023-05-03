import 'dart:collection';

import 'package:game_template/screens/games/chess/chess_logic.dart';
import 'package:game_template/services/extensions/iterable_extensions.dart';
import 'package:logging/logging.dart';
Logger _logger = Logger("Chess piece logic");

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
    for(int i = 0;  i < notation.length; i++){
      int character = notation.codeUnitAt(i);
      if(character >= 48 && character < 58){
        rankIntString += "${character - 48}";
      }else if(character >= 97 && character < 123){
        fileIntString += "${character - 96}";
      }
      _logger.warning("$character => $fileIntString,$rankIntString");
    }
    file = int.parse(fileIntString);
    rank = int.parse(rankIntString);
  }

  @override
  int compareTo(other) {
    // if(!inside){
    //   throw "outside compare to";
    // }
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

  static ChessPiece? getFirstAlivePieceIfInLocation(List<ChessPiece> chessPieces, ChessLocation? location){
    return chessPieces.firstWhereIfThere((element) {
      return !element.eaten && location == element.location;
    });
  }


  static bool isInCheck(bool isWhite){
    return false;
  }

  static List<MapEntry<ChessLocation, ChessPiece?>> getPossibleMovesForPiece(ChessPiece chessPiece, ChessBoardState gameState){

    if(gameState.isWhiteTurn && chessPiece.isWhite){//movesForWhite
      _logger.fine("Moves only for white");
      switch(chessPiece.pieceType){
        case ChessPieceType.Pawn:
          List<MapEntry<ChessLocation, ChessPiece?>> pawnLocations= [];
          if(gameState.lastEnPassantMove!=null){//en passant move
            ChessPiece? lastEnPassantMovedPiece = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, gameState.lastEnPassantMove);
            if(lastEnPassantMovedPiece !=null && !lastEnPassantMovedPiece.isWhite && chessPiece.location.rank == gameState.lastEnPassantMove!.rank
                && (chessPiece.location.file - gameState.lastEnPassantMove!.file).abs() == 1
            ){
              pawnLocations.add(
                MapEntry(
                  ChessLocation(
                    rank: chessPiece.location.rank + 1,
                    file: gameState.lastEnPassantMove!.file
                ), lastEnPassantMovedPiece)
              );//enPassantMove if possible added
            }
          }

          pawnLocations.addAll([
          ...gameState.gamePieces.where((element){
              return !element.eaten && !element.isWhite
                && (chessPiece.location.file - element.location.file).abs() == 1
                && chessPiece.location.rank + 1 == element.location.rank;
            }).map((e) => MapEntry(e.location, e)).toList()
          ]);//the two adjacent pawns if there

          //add forwardMove if not blocked;
          bool firstMovePossible = !gameState.gamePieces.any((element) {
            return !element.eaten
                && chessPiece.location.rank + 1 == element.location.rank;
          });
          bool secondMovePossible = chessPiece.location.rank == 2 && !gameState.gamePieces.any((element) {
            return !element.eaten
                && chessPiece.location.rank + 2 == element.location.rank;
          });

          if(secondMovePossible){
            pawnLocations.add(MapEntry(ChessLocation(rank: chessPiece.location.rank + 1, file: chessPiece.location.file), null));
            pawnLocations.add(MapEntry(ChessLocation(rank: chessPiece.location.rank + 2, file: chessPiece.location.file), null));
          }else if(firstMovePossible){
            pawnLocations.add(MapEntry(ChessLocation(rank: chessPiece.location.rank + 1, file: chessPiece.location.file), null));
          }

          return pawnLocations.where((element) => element.key.inside).toList();
        case ChessPieceType.Knight:
          List<ChessLocation> knightJumps = [
            ChessLocation(rank: chessPiece.location.rank + 1, file: chessPiece.location.file + 2),
            ChessLocation(rank: chessPiece.location.rank + 1, file: chessPiece.location.file - 2),
            ChessLocation(rank: chessPiece.location.rank - 1, file: chessPiece.location.file + 2),
            ChessLocation(rank: chessPiece.location.rank - 1, file: chessPiece.location.file - 2),
            ChessLocation(rank: chessPiece.location.rank + 2, file: chessPiece.location.file + 1),
            ChessLocation(rank: chessPiece.location.rank + 2, file: chessPiece.location.file - 1),
            ChessLocation(rank: chessPiece.location.rank - 2, file: chessPiece.location.file + 1),
            ChessLocation(rank: chessPiece.location.rank - 2, file: chessPiece.location.file - 1),
          ];
          List<MapEntry<ChessLocation, ChessPiece?>> knightLocations = [];
          for(ChessLocation location in knightJumps){
            ChessPiece? pieceInLocation = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, location);
            if(pieceInLocation == null){
              knightLocations.add(MapEntry(location, null));
            }else{
              if(!pieceInLocation.isWhite){
                knightLocations.add(MapEntry(location, pieceInLocation));
              }
            }
          }
          return knightLocations.where((element) => element.key.inside).toList();
        case ChessPieceType.Bishop:
          List<MapEntry<ChessLocation, ChessPiece?>> bishopMoves = [];
          int rankDx = 1;
          List<bool> stoppedTlTrBlBR = [
            false,
            false,
            false,
            false,
          ];
          while(stoppedTlTrBlBR.any((element) => !element)){
            _logger.info("$rankDx loop -> { $stoppedTlTrBlBR}");
            if(!stoppedTlTrBlBR[0]){//Top Left
              ChessLocation toThisLocation = ChessLocation(
                rank: chessPiece.location.rank + rankDx,
                file: chessPiece.location.file - rankDx
              );
              if(!toThisLocation.inside){
                stoppedTlTrBlBR[0]=true;
              }
              ChessPiece? pieceStopping = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, toThisLocation);
              if(pieceStopping == null){
                bishopMoves.add(MapEntry(toThisLocation, null));
              }else{
                if(!pieceStopping.isWhite){
                  bishopMoves.add(MapEntry(toThisLocation, pieceStopping));
                }
                stoppedTlTrBlBR[0]=true;
              }
            }
            if(!stoppedTlTrBlBR[1]){//Top Right
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank + rankDx,
                  file: chessPiece.location.file + rankDx
              );
              if(!toThisLocation.inside){
                stoppedTlTrBlBR[1]=true;
              }
              ChessPiece? pieceStopping = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, toThisLocation);
              if(pieceStopping == null){
                bishopMoves.add(MapEntry(toThisLocation, null));
              }else{
                if(!pieceStopping.isWhite){
                  bishopMoves.add(MapEntry(toThisLocation, pieceStopping));
                }
                stoppedTlTrBlBR[1]=true;
              }
            }
            if(!stoppedTlTrBlBR[2]){//Bottom Left
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank - rankDx,
                  file: chessPiece.location.file - rankDx
              );
              if(!toThisLocation.inside){
                stoppedTlTrBlBR[2]=true;
              }
              ChessPiece? pieceStopping = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, toThisLocation);
              if(pieceStopping == null){
                bishopMoves.add(MapEntry(toThisLocation, null));
              }else{
                if(!pieceStopping.isWhite){
                  bishopMoves.add(MapEntry(toThisLocation, pieceStopping));
                }
                stoppedTlTrBlBR[2]=true;
              }
            }
            if(!stoppedTlTrBlBR[3]){//Bottom Right
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank - rankDx,
                  file: chessPiece.location.file + rankDx
              );
              if(!toThisLocation.inside){
                stoppedTlTrBlBR[3]=true;
              }
              ChessPiece? pieceStopping = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, toThisLocation);
              if(pieceStopping == null){
                bishopMoves.add(MapEntry(toThisLocation, null));
              }else{
                if(!pieceStopping.isWhite){
                  bishopMoves.add(MapEntry(toThisLocation, pieceStopping));
                }
                stoppedTlTrBlBR[3]=true;
              }
            }
            rankDx++;
          }
          return bishopMoves;
        case ChessPieceType.Rook:
          List<MapEntry<ChessLocation, ChessPiece?>> rookMoves = [];
          int rankDx = 1;
          List<bool> stoppedTBLR = [
            false,
            false,
            false,
            false,
          ];
          while(stoppedTBLR.any((element) => !element)){
            _logger.info("$rankDx loop -> { $stoppedTBLR}");
            if(!stoppedTBLR[0]){//Top
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank + rankDx,
                  file: chessPiece.location.file
              );
              if(!toThisLocation.inside){
                stoppedTBLR[0]=true;
              }
              ChessPiece? pieceStopping = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, toThisLocation);
              if(pieceStopping == null){
                rookMoves.add(MapEntry(toThisLocation, null));
              }else{
                if(!pieceStopping.isWhite){
                  rookMoves.add(MapEntry(toThisLocation, pieceStopping));
                }
                stoppedTBLR[0]=true;
              }
            }
            if(!stoppedTBLR[1]){//Bottom
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank - rankDx,
                  file: chessPiece.location.file
              );
              if(!toThisLocation.inside){
                stoppedTBLR[1]=true;
              }
              ChessPiece? pieceStopping = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, toThisLocation);
              if(pieceStopping == null){
                rookMoves.add(MapEntry(toThisLocation, null));
              }else{
                if(!pieceStopping.isWhite){
                  rookMoves.add(MapEntry(toThisLocation, pieceStopping));
                }
                stoppedTBLR[1]=true;
              }
            }
            if(!stoppedTBLR[2]){//Left
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank,
                  file: chessPiece.location.file - rankDx
              );
              if(!toThisLocation.inside){
                stoppedTBLR[2]=true;
              }
              ChessPiece? pieceStopping = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, toThisLocation);
              if(pieceStopping == null){
                rookMoves.add(MapEntry(toThisLocation, null));
              }else{
                if(!pieceStopping.isWhite){
                  rookMoves.add(MapEntry(toThisLocation, pieceStopping));
                }
                stoppedTBLR[2]=true;
              }
            }
            if(!stoppedTBLR[3]){//Right
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank,
                  file: chessPiece.location.file + rankDx
              );
              if(!toThisLocation.inside){
                stoppedTBLR[3]=true;
              }
              ChessPiece? pieceStopping = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, toThisLocation);
              if(pieceStopping == null){
                rookMoves.add(MapEntry(toThisLocation, null));
              }else{
                if(!pieceStopping.isWhite){
                  rookMoves.add(MapEntry(toThisLocation, pieceStopping));
                }
                stoppedTBLR[3]=true;
              }
            }
            rankDx++;
          }
          return rookMoves;
        case ChessPieceType.Queen:
          List<MapEntry<ChessLocation, ChessPiece?>> queenMoves = [];
          int rankDx = 1;
          List<bool> stoppedTBLRQEZC = [
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
          ];
          while(stoppedTBLRQEZC.any((element) => !element)){
            _logger.info("$rankDx loop -> { $stoppedTBLRQEZC}");
            if(!stoppedTBLRQEZC[0]){//Top
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank + rankDx,
                  file: chessPiece.location.file
              );
              if(!toThisLocation.inside){
                stoppedTBLRQEZC[0]=true;
              }
              ChessPiece? pieceStopping = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, toThisLocation);
              if(pieceStopping == null){
                queenMoves.add(MapEntry(toThisLocation, null));
              }else{
                if(!pieceStopping.isWhite){
                  queenMoves.add(MapEntry(toThisLocation, pieceStopping));
                }
                stoppedTBLRQEZC[0]=true;
              }
            }
            if(!stoppedTBLRQEZC[1]){//Bottom
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank - rankDx,
                  file: chessPiece.location.file
              );
              if(!toThisLocation.inside){
                stoppedTBLRQEZC[1]=true;
              }
              ChessPiece? pieceStopping = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, toThisLocation);
              if(pieceStopping == null){
                queenMoves.add(MapEntry(toThisLocation, null));
              }else{
                if(!pieceStopping.isWhite){
                  queenMoves.add(MapEntry(toThisLocation, pieceStopping));
                }
                stoppedTBLRQEZC[1]=true;
              }
            }
            if(!stoppedTBLRQEZC[2]){//Left
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank,
                  file: chessPiece.location.file - rankDx
              );
              if(!toThisLocation.inside){
                stoppedTBLRQEZC[2]=true;
              }
              ChessPiece? pieceStopping = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, toThisLocation);
              if(pieceStopping == null){
                queenMoves.add(MapEntry(toThisLocation, null));
              }else{
                if(!pieceStopping.isWhite){
                  queenMoves.add(MapEntry(toThisLocation, pieceStopping));
                }
                stoppedTBLRQEZC[2]=true;
              }
            }
            if(!stoppedTBLRQEZC[3]){//Right
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank,
                  file: chessPiece.location.file + rankDx
              );
              if(!toThisLocation.inside){
                stoppedTBLRQEZC[3]=true;
              }
              ChessPiece? pieceStopping = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, toThisLocation);
              if(pieceStopping == null){
                queenMoves.add(MapEntry(toThisLocation, null));
              }else{
                if(!pieceStopping.isWhite){
                  queenMoves.add(MapEntry(toThisLocation, pieceStopping));
                }
                stoppedTBLRQEZC[3]=true;
              }
            }
            if(!stoppedTBLRQEZC[4]){//Top Left Q
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank + rankDx,
                  file: chessPiece.location.file - rankDx
              );
              if(!toThisLocation.inside){
                stoppedTBLRQEZC[4]=true;
              }
              ChessPiece? pieceStopping = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, toThisLocation);
              if(pieceStopping == null){
                queenMoves.add(MapEntry(toThisLocation, null));
              }else{
                if(!pieceStopping.isWhite){
                  queenMoves.add(MapEntry(toThisLocation, pieceStopping));
                }
                stoppedTBLRQEZC[4]=true;
              }
            }
            if(!stoppedTBLRQEZC[5]){//Top Right
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank + rankDx,
                  file: chessPiece.location.file + rankDx
              );
              if(!toThisLocation.inside){
                stoppedTBLRQEZC[5]=true;
              }
              ChessPiece? pieceStopping = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, toThisLocation);
              if(pieceStopping == null){
                queenMoves.add(MapEntry(toThisLocation, null));
              }else{
                if(!pieceStopping.isWhite){
                  queenMoves.add(MapEntry(toThisLocation, pieceStopping));
                }
                stoppedTBLRQEZC[5]=true;
              }
            }
            if(!stoppedTBLRQEZC[6]){//Bottom Left Z
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank - rankDx,
                  file: chessPiece.location.file - rankDx
              );
              if(!toThisLocation.inside){
                stoppedTBLRQEZC[6]=true;
              }
              ChessPiece? pieceStopping = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, toThisLocation);
              if(pieceStopping == null){
                queenMoves.add(MapEntry(toThisLocation, null));
              }else{
                if(!pieceStopping.isWhite){
                  queenMoves.add(MapEntry(toThisLocation, pieceStopping));
                }
                stoppedTBLRQEZC[6]=true;
              }
            }
            if(!stoppedTBLRQEZC[7]){//Bottom Right C
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank - rankDx,
                  file: chessPiece.location.file + rankDx
              );
              if(!toThisLocation.inside){
                stoppedTBLRQEZC[7]=true;
              }
              ChessPiece? pieceStopping = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, toThisLocation);
              if(pieceStopping == null){
                queenMoves.add(MapEntry(toThisLocation, null));
              }else{
                if(!pieceStopping.isWhite){
                  queenMoves.add(MapEntry(toThisLocation, pieceStopping));
                }
                stoppedTBLRQEZC[7]=true;
              }
            }
            rankDx++;
          }
          return queenMoves;
        case ChessPieceType.King:
          List<ChessLocation> knightJumps = [
            ChessLocation(rank: chessPiece.location.rank + 1, file: chessPiece.location.file - 1),
            ChessLocation(rank: chessPiece.location.rank + 1, file: chessPiece.location.file + 0),
            ChessLocation(rank: chessPiece.location.rank + 1, file: chessPiece.location.file + 1),
            ChessLocation(rank: chessPiece.location.rank + 0, file: chessPiece.location.file - 1),
            ChessLocation(rank: chessPiece.location.rank + 0, file: chessPiece.location.file + 1),
            ChessLocation(rank: chessPiece.location.rank - 1, file: chessPiece.location.file - 1),
            ChessLocation(rank: chessPiece.location.rank - 1, file: chessPiece.location.file + 0),
            ChessLocation(rank: chessPiece.location.rank - 1, file: chessPiece.location.file + 1),
          ];
          List<MapEntry<ChessLocation, ChessPiece?>> knightLocations = [];
          for(ChessLocation location in knightJumps){
            ChessPiece? pieceInLocation = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, location);
            if(pieceInLocation == null){
              knightLocations.add(MapEntry(location, null));
            }else{
              if(!pieceInLocation.isWhite){
                knightLocations.add(MapEntry(location, pieceInLocation));
              }
            }
          }
          return knightLocations.where((element) => element.key.inside).toList();
      }
    }else if(!gameState.isWhiteTurn && !chessPiece.isWhite){//Moves for black
      _logger.fine("Moves only for black");
      switch(chessPiece.pieceType){
        case ChessPieceType.Pawn:
          List<MapEntry<ChessLocation, ChessPiece?>> pawnLocations= [];
          if(gameState.lastEnPassantMove!=null){//en passant move
            ChessPiece? lastEnPassantMovedPiece = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, gameState.lastEnPassantMove);
            if(lastEnPassantMovedPiece !=null && lastEnPassantMovedPiece.isWhite && chessPiece.location.rank == gameState.lastEnPassantMove!.rank
                && (chessPiece.location.file - gameState.lastEnPassantMove!.file).abs() == 1
            ){
              pawnLocations.add(
                  MapEntry(
                      ChessLocation(
                          rank: chessPiece.location.rank + 1,
                          file: gameState.lastEnPassantMove!.file
                      ), lastEnPassantMovedPiece)
              );//enPassantMove if possible added
            }
          }
          pawnLocations.addAll([
            ...gameState.gamePieces.where((element){
              return !element.eaten && element.isWhite
                  && (chessPiece.location.file - element.location.file).abs() == 1
                  && chessPiece.location.rank + 1 == element.location.rank;
            }).map((e) => MapEntry(e.location, e)).toList()
          ]);//the two adjacent pawns if there

          //add forwardMove if not blocked;
          bool firstMovePossible = !gameState.gamePieces.any((element) {
            return !element.eaten
                && chessPiece.location.rank + 1 == element.location.rank;
          });
          bool secondMovePossible = chessPiece.location.rank == 2 && !gameState.gamePieces.any((element) {
            return !element.eaten
                && chessPiece.location.rank + 2 == element.location.rank;
          });

          if(secondMovePossible){
            pawnLocations.add(MapEntry(ChessLocation(rank: chessPiece.location.rank + 1, file: chessPiece.location.file), null));
            pawnLocations.add(MapEntry(ChessLocation(rank: chessPiece.location.rank + 2, file: chessPiece.location.file), null));
          }else if(firstMovePossible){
            pawnLocations.add(MapEntry(ChessLocation(rank: chessPiece.location.rank + 1, file: chessPiece.location.file), null));
          }

          return pawnLocations.where((element) => element.key.inside).toList();
        case ChessPieceType.Knight:
          List<ChessLocation> knightJumps = [
            ChessLocation(rank: chessPiece.location.rank + 1, file: chessPiece.location.file + 2),
            ChessLocation(rank: chessPiece.location.rank + 1, file: chessPiece.location.file - 2),
            ChessLocation(rank: chessPiece.location.rank - 1, file: chessPiece.location.file + 2),
            ChessLocation(rank: chessPiece.location.rank - 1, file: chessPiece.location.file - 2),
            ChessLocation(rank: chessPiece.location.rank + 2, file: chessPiece.location.file + 1),
            ChessLocation(rank: chessPiece.location.rank + 2, file: chessPiece.location.file - 1),
            ChessLocation(rank: chessPiece.location.rank - 2, file: chessPiece.location.file + 1),
            ChessLocation(rank: chessPiece.location.rank - 2, file: chessPiece.location.file - 1),
          ];
          List<MapEntry<ChessLocation, ChessPiece?>> knightLocations = [];
          for(ChessLocation location in knightJumps){
            ChessPiece? pieceInLocation = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, location);
            if(pieceInLocation == null){
              knightLocations.add(MapEntry(location, null));
            }else{
              if(pieceInLocation.isWhite){
                knightLocations.add(MapEntry(location, pieceInLocation));
              }
            }
          }
          return knightLocations.where((element) => element.key.inside).toList();
        case ChessPieceType.Bishop:
          List<MapEntry<ChessLocation, ChessPiece?>> bishopMoves = [];
          int rankDx = 1;
          List<bool> stoppedTlTrBlBR = [
            false,
            false,
            false,
            false,
          ];
          while(stoppedTlTrBlBR.any((element) => !element)){
            _logger.info("$rankDx loop -> { $stoppedTlTrBlBR}");
            if(!stoppedTlTrBlBR[0]){//Top Left
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank + rankDx,
                  file: chessPiece.location.file - rankDx
              );
              if(!toThisLocation.inside){
                stoppedTlTrBlBR[0]=true;
              }
              ChessPiece? pieceStopping = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, toThisLocation);
              if(pieceStopping == null){
                bishopMoves.add(MapEntry(toThisLocation, null));
              }else{
                if(pieceStopping.isWhite){
                  bishopMoves.add(MapEntry(toThisLocation, pieceStopping));
                }
                stoppedTlTrBlBR[0]=true;
              }
            }
            if(!stoppedTlTrBlBR[1]){//Top Right
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank + rankDx,
                  file: chessPiece.location.file + rankDx
              );
              if(!toThisLocation.inside){
                stoppedTlTrBlBR[1]=true;
              }
              ChessPiece? pieceStopping = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, toThisLocation);
              if(pieceStopping == null){
                bishopMoves.add(MapEntry(toThisLocation, null));
              }else{
                if(pieceStopping.isWhite){
                  bishopMoves.add(MapEntry(toThisLocation, pieceStopping));
                }
                stoppedTlTrBlBR[1]=true;
              }
            }
            if(!stoppedTlTrBlBR[2]){//Bottom Left
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank - rankDx,
                  file: chessPiece.location.file - rankDx
              );
              if(!toThisLocation.inside){
                stoppedTlTrBlBR[2]=true;
              }
              ChessPiece? pieceStopping = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, toThisLocation);
              if(pieceStopping == null){
                bishopMoves.add(MapEntry(toThisLocation, null));
              }else{
                if(pieceStopping.isWhite){
                  bishopMoves.add(MapEntry(toThisLocation, pieceStopping));
                }
                stoppedTlTrBlBR[2]=true;
              }
            }
            if(!stoppedTlTrBlBR[3]){//Bottom Right
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank - rankDx,
                  file: chessPiece.location.file + rankDx
              );
              if(!toThisLocation.inside){
                stoppedTlTrBlBR[3]=true;
              }
              ChessPiece? pieceStopping = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, toThisLocation);
              if(pieceStopping == null){
                bishopMoves.add(MapEntry(toThisLocation, null));
              }else{
                if(pieceStopping.isWhite){
                  bishopMoves.add(MapEntry(toThisLocation, pieceStopping));
                }
                stoppedTlTrBlBR[3]=true;
              }
            }
            rankDx++;
          }
          return bishopMoves;
        case ChessPieceType.Rook:
          List<MapEntry<ChessLocation, ChessPiece?>> rookMoves = [];
          int rankDx = 1;
          List<bool> stoppedTBLR = [
            false,
            false,
            false,
            false,
          ];
          while(stoppedTBLR.any((element) => !element)){
            _logger.info("$rankDx loop -> { $stoppedTBLR}");
            if(!stoppedTBLR[0]){//Top
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank + rankDx,
                  file: chessPiece.location.file
              );
              if(!toThisLocation.inside){
                stoppedTBLR[0]=true;
              }
              ChessPiece? pieceStopping = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, toThisLocation);
              if(pieceStopping == null){
                rookMoves.add(MapEntry(toThisLocation, null));
              }else{
                if(pieceStopping.isWhite){
                  rookMoves.add(MapEntry(toThisLocation, pieceStopping));
                }
                stoppedTBLR[0]=true;
              }
            }
            if(!stoppedTBLR[1]){//Bottom
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank - rankDx,
                  file: chessPiece.location.file
              );
              if(!toThisLocation.inside){
                stoppedTBLR[1]=true;
              }
              ChessPiece? pieceStopping = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, toThisLocation);
              if(pieceStopping == null){
                rookMoves.add(MapEntry(toThisLocation, null));
              }else{
                if(pieceStopping.isWhite){
                  rookMoves.add(MapEntry(toThisLocation, pieceStopping));
                }
                stoppedTBLR[1]=true;
              }
            }
            if(!stoppedTBLR[2]){//Left
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank,
                  file: chessPiece.location.file - rankDx
              );
              if(!toThisLocation.inside){
                stoppedTBLR[2]=true;
              }
              ChessPiece? pieceStopping = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, toThisLocation);
              if(pieceStopping == null){
                rookMoves.add(MapEntry(toThisLocation, null));
              }else{
                if(pieceStopping.isWhite){
                  rookMoves.add(MapEntry(toThisLocation, pieceStopping));
                }
                stoppedTBLR[2]=true;
              }
            }
            if(!stoppedTBLR[3]){//Right
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank,
                  file: chessPiece.location.file + rankDx
              );
              if(!toThisLocation.inside){
                stoppedTBLR[3]=true;
              }
              ChessPiece? pieceStopping = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, toThisLocation);
              if(pieceStopping == null){
                rookMoves.add(MapEntry(toThisLocation, null));
              }else{
                if(pieceStopping.isWhite){
                  rookMoves.add(MapEntry(toThisLocation, pieceStopping));
                }
                stoppedTBLR[3]=true;
              }
            }
            rankDx++;
          }
          return rookMoves;
        case ChessPieceType.Queen:
          List<MapEntry<ChessLocation, ChessPiece?>> queenMoves = [];
          int rankDx = 1;
          List<bool> stoppedTBLRQEZC = [
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
          ];
          while(stoppedTBLRQEZC.any((element) => !element)){
            _logger.info("$rankDx loop -> { $stoppedTBLRQEZC}");
            if(!stoppedTBLRQEZC[0]){//Top
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank + rankDx,
                  file: chessPiece.location.file
              );
              if(!toThisLocation.inside){
                stoppedTBLRQEZC[0]=true;
              }
              ChessPiece? pieceStopping = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, toThisLocation);
              if(pieceStopping == null){
                queenMoves.add(MapEntry(toThisLocation, null));
              }else{
                if(pieceStopping.isWhite){
                  queenMoves.add(MapEntry(toThisLocation, pieceStopping));
                }
                stoppedTBLRQEZC[0]=true;
              }
            }
            if(!stoppedTBLRQEZC[1]){//Bottom
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank - rankDx,
                  file: chessPiece.location.file
              );
              if(!toThisLocation.inside){
                stoppedTBLRQEZC[1]=true;
              }
              ChessPiece? pieceStopping = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, toThisLocation);
              if(pieceStopping == null){
                queenMoves.add(MapEntry(toThisLocation, null));
              }else{
                if(pieceStopping.isWhite){
                  queenMoves.add(MapEntry(toThisLocation, pieceStopping));
                }
                stoppedTBLRQEZC[1]=true;
              }
            }
            if(!stoppedTBLRQEZC[2]){//Left
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank,
                  file: chessPiece.location.file - rankDx
              );
              if(!toThisLocation.inside){
                stoppedTBLRQEZC[2]=true;
              }
              ChessPiece? pieceStopping = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, toThisLocation);
              if(pieceStopping == null){
                queenMoves.add(MapEntry(toThisLocation, null));
              }else{
                if(pieceStopping.isWhite){
                  queenMoves.add(MapEntry(toThisLocation, pieceStopping));
                }
                stoppedTBLRQEZC[2]=true;
              }
            }
            if(!stoppedTBLRQEZC[3]){//Right
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank,
                  file: chessPiece.location.file + rankDx
              );
              if(!toThisLocation.inside){
                stoppedTBLRQEZC[3]=true;
              }
              ChessPiece? pieceStopping = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, toThisLocation);
              if(pieceStopping == null){
                queenMoves.add(MapEntry(toThisLocation, null));
              }else{
                if(pieceStopping.isWhite){
                  queenMoves.add(MapEntry(toThisLocation, pieceStopping));
                }
                stoppedTBLRQEZC[3]=true;
              }
            }
            if(!stoppedTBLRQEZC[4]){//Top Left Q
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank + rankDx,
                  file: chessPiece.location.file - rankDx
              );
              if(!toThisLocation.inside){
                stoppedTBLRQEZC[4]=true;
              }
              ChessPiece? pieceStopping = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, toThisLocation);
              if(pieceStopping == null){
                queenMoves.add(MapEntry(toThisLocation, null));
              }else{
                if(pieceStopping.isWhite){
                  queenMoves.add(MapEntry(toThisLocation, pieceStopping));
                }
                stoppedTBLRQEZC[4]=true;
              }
            }
            if(!stoppedTBLRQEZC[5]){//Top Right
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank + rankDx,
                  file: chessPiece.location.file + rankDx
              );
              if(!toThisLocation.inside){
                stoppedTBLRQEZC[5]=true;
              }
              ChessPiece? pieceStopping = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, toThisLocation);
              if(pieceStopping == null){
                queenMoves.add(MapEntry(toThisLocation, null));
              }else{
                if(pieceStopping.isWhite){
                  queenMoves.add(MapEntry(toThisLocation, pieceStopping));
                }
                stoppedTBLRQEZC[5]=true;
              }
            }
            if(!stoppedTBLRQEZC[6]){//Bottom Left Z
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank - rankDx,
                  file: chessPiece.location.file - rankDx
              );
              if(!toThisLocation.inside){
                stoppedTBLRQEZC[6]=true;
              }
              ChessPiece? pieceStopping = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, toThisLocation);
              if(pieceStopping == null){
                queenMoves.add(MapEntry(toThisLocation, null));
              }else{
                if(pieceStopping.isWhite){
                  queenMoves.add(MapEntry(toThisLocation, pieceStopping));
                }
                stoppedTBLRQEZC[6]=true;
              }
            }
            if(!stoppedTBLRQEZC[7]){//Bottom Right C
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank - rankDx,
                  file: chessPiece.location.file + rankDx
              );
              if(!toThisLocation.inside){
                stoppedTBLRQEZC[7]=true;
              }
              ChessPiece? pieceStopping = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, toThisLocation);
              if(pieceStopping == null){
                queenMoves.add(MapEntry(toThisLocation, null));
              }else{
                if(pieceStopping.isWhite){
                  queenMoves.add(MapEntry(toThisLocation, pieceStopping));
                }
                stoppedTBLRQEZC[7]=true;
              }
            }
            rankDx++;
          }
          return queenMoves;
        case ChessPieceType.King:
          List<ChessLocation> knightJumps = [
            ChessLocation(rank: chessPiece.location.rank + 1, file: chessPiece.location.file - 1),
            ChessLocation(rank: chessPiece.location.rank + 1, file: chessPiece.location.file + 0),
            ChessLocation(rank: chessPiece.location.rank + 1, file: chessPiece.location.file + 1),
            ChessLocation(rank: chessPiece.location.rank + 0, file: chessPiece.location.file - 1),
            ChessLocation(rank: chessPiece.location.rank + 0, file: chessPiece.location.file + 1),
            ChessLocation(rank: chessPiece.location.rank - 1, file: chessPiece.location.file - 1),
            ChessLocation(rank: chessPiece.location.rank - 1, file: chessPiece.location.file + 0),
            ChessLocation(rank: chessPiece.location.rank - 1, file: chessPiece.location.file + 1),
          ];
          List<MapEntry<ChessLocation, ChessPiece?>> knightLocations = [];
          for(ChessLocation location in knightJumps){
            ChessPiece? pieceInLocation = Movement.getFirstAlivePieceIfInLocation(gameState.gamePieces, location);
            if(pieceInLocation == null){
              knightLocations.add(MapEntry(location, null));
            }else{
              if(pieceInLocation.isWhite){
                knightLocations.add(MapEntry(location, pieceInLocation));
              }
            }
          }
          return knightLocations.where((element) => element.key.inside).toList();
      }
    }

    return [];
  }


}