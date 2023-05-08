
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:game_template/screens/games/chess/chess_piece_logic.dart';
import 'package:logging/logging.dart';

enum ChessGameState{
  WhiteWin,
  BlackWin,
  Draw,
  None,
}

class ChessBoardState{
  Logger _logger = Logger("ChessBoardState");
  static const String defaultStartingFen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";
  static const int SQUARE = 8;

  late bool isWhiteTurn;
  late bool blackQueenSide;
  late bool blackKingSide;
  late bool whiteQueenSide;
  late bool whiteKingSide;
  ChessLocation? lastEnPassantMove;
  List<ChessPiece> gamePieces = [];
  late int halfMovesFromCoPM;
  late int totalFullMoves;
  ChessGameState gameState = ChessGameState.None;

  String get actualFen => toFen();
  List<ChessPiece> get aliveGamePieces => gamePieces.where((element) => !element.eaten).toList();
  List<ChessPiece> get deadGamePieces => gamePieces.where((element) => element.eaten).toList();


  ChessBoardState({
    String? initFen,
  }){
    fenParser(initFen ?? defaultStartingFen);
  }

  setMoves(List<Movement> moveOfTurn){
    // _logger.info(moveOfTurn);
    // _logger.info(gamePieces);
    // ChessBoardState prev = ChessBoardState(initFen: toFen());
    bool moveDone = false;
    for (int i = 0; i < moveOfTurn.length; i++){
      for(int j = 0; j < gamePieces.length; j++){
        if(gamePieces[j] == moveOfTurn[i].from){
          gamePieces[j] = moveOfTurn[i].to;
          moveDone = true;
          break;
        }
      }
    }
    // _logger.info(gamePieces);
    // log("Prev: $prev, Now: $this -----> ${prev == this}");
    if(moveDone){
      isWhiteTurn = !isWhiteTurn;
    }
  }

  fenParser(String fen){
    List<String> rules = fen.split(" ");
    if(rules.length == 6){
      String piecePlacement = rules[0];
      String nextPlayerMove = rules[1];
      assert(nextPlayerMove == "w" || nextPlayerMove == "b" );
      String castlingRights = rules[2];
      assert(castlingRights.contains(RegExp("(k|q|K|q|-)")));
      String enPassantPlayed = rules[3];
      assert(enPassantPlayed.contains(RegExp("([a-h][0-8]|-)")));
      String halfMove = rules[4];
      assert(int.tryParse(halfMove)!=null);
      String fullMove = rules[5];
      assert(int.tryParse(fullMove)!=null);

      isWhiteTurn = nextPlayerMove == "w";
      whiteKingSide = castlingRights.contains("K");
      whiteQueenSide = castlingRights.contains("Q");
      blackKingSide = castlingRights.contains("k");
      blackQueenSide = castlingRights.contains("q");
      halfMovesFromCoPM = int.parse(halfMove);
      totalFullMoves = int.parse(fullMove);
      lastEnPassantMove = enPassantPlayed == "-" ? null : ChessLocation.fromChessNotation(enPassantPlayed);

      fenPieceParser(piecePlacement);
    }else{
      throw "fan input is not correct is it doesn't feature all 6 rules";
    }
  }

  fenPieceParser(String fenPieces){
    List<String> fenPieceInRanks = fenPieces.split("/");
    List<ChessPiece> pieces = [];
    if(fenPieceInRanks.length == SQUARE){
      int rank = 1;
      for(int i = 0 ; i < fenPieceInRanks.length; i++){
        rank = 8-i;
        int file = 1;
        for(int j = 0; j < fenPieceInRanks[i].length; j++) {
          assert(fenPieceInRanks[i][j].contains(RegExp("(r|b|n|k|q|p|R|B|N|K|Q|P|[0-8])")));
          int? emptySpaces = int.tryParse(fenPieceInRanks[i][j]);
          if(emptySpaces == null){
            bool isWhite = fenPieceInRanks[i][j].toUpperCase() == fenPieceInRanks[i][j] && fenPieceInRanks[i][j].isNotEmpty;
            switch(fenPieceInRanks[i][j].toUpperCase()){
              case "R":
                pieces.add(ChessPiece(
                  location: ChessLocation(rank: rank, file:  file),
                  isWhite: isWhite,
                  pieceType: ChessPieceType.Rook
                ));
                file++;
                break;
              case "B":
                pieces.add(ChessPiece(
                  location: ChessLocation(rank: rank, file:  file),
                  isWhite: isWhite,
                  pieceType: ChessPieceType.Bishop
                ));
                file++;
                break;
              case "N":
                pieces.add(ChessPiece(
                  location: ChessLocation(rank: rank, file:  file),
                  isWhite: isWhite,
                  pieceType: ChessPieceType.Knight
                ));
                file++;
                break;
              case "K":
                pieces.add(ChessPiece(
                  location: ChessLocation(rank: rank, file:  file),
                  isWhite: isWhite,
                  pieceType: ChessPieceType.King
                ));
                file++;
                break;
              case "Q":
                pieces.add(ChessPiece(
                  location: ChessLocation(rank: rank, file:  file),
                  isWhite: isWhite,
                  pieceType: ChessPieceType.Queen
                ));
                file++;
                break;
              case "P":
                pieces.add(ChessPiece(
                  location: ChessLocation(rank: rank, file:  file),
                  isWhite: isWhite,
                  pieceType: ChessPieceType.Pawn
                ));
                file++;
                break;
              default:
                assert(false);
                break;
            }
          }else{
            file += emptySpaces;
          }
        }
      }
      gamePieces = pieces;
    }else{
      throw "fan piece input is not correct or it doesn't feature 8 ranks";
    }
  }

  String toFen(){
    StringBuffer bufferResult = StringBuffer();

    for(int i = 0; i < SQUARE ; i++){
      List<ChessPiece> listPieces = gamePieces.where((element) {
        return !element.eaten && element.location.rank == SQUARE-i;
      }).toList();

      int numToAdd = 0;
      for(int j = 0; j < SQUARE; j++){
        if(listPieces.any((element) => element.location.file == j+1)){
          if(numToAdd != 0){
            bufferResult.write(String.fromCharCode(48+numToAdd));
          }
          bufferResult.write(listPieces.firstWhere((element) => element.location.file == j+1).pieceCodeColor);
          numToAdd = 0;
        }else{
          numToAdd++;
        }
      }

      if(numToAdd!=0){
        bufferResult.write(String.fromCharCode(48+numToAdd));
      }
      if(i!=SQUARE-1){
        bufferResult.write("/");
      }
    }
    bufferResult.write(" ");
    bufferResult.write(isWhiteTurn ? "w" : "b");
    bufferResult.write(" ");
    if(whiteKingSide || whiteQueenSide || blackKingSide || blackQueenSide){
      bufferResult..write(whiteKingSide?"K":"")..write(whiteQueenSide?"Q":"")..write(blackKingSide?"k":"")..write(blackQueenSide?"q":"");
    }else{
      bufferResult.write("-");
    }
    bufferResult.write(" ");
    if(lastEnPassantMove == null || lastEnPassantMove?.inside == true) {
      bufferResult.write("-");
    }else{
      bufferResult.write(lastEnPassantMove!.nameConvention);
    }
    bufferResult.write(" ");
    bufferResult.write("$halfMovesFromCoPM");
    bufferResult.write(" ");
    bufferResult.write("$totalFullMoves");

    return bufferResult.toString();
  }

  @override
  String toString() {
    return {
      "gs": this.gameState.name,
      "pieces": this.gamePieces,
      "enPass?": this.lastEnPassantMove,
      "turn":this.isWhiteTurn ? "white": "black",
      "fen":this.actualFen
    }.toString();
  }

  @override
  bool operator ==(Object other) {
    return other is ChessBoardState
      && setEquals(Set.unmodifiable(this.gamePieces), Set.unmodifiable(other.gamePieces))
      && this.blackKingSide == other.blackKingSide
      && this.blackQueenSide == other.blackQueenSide
      && this.whiteKingSide == other.whiteKingSide
      && this.whiteQueenSide == other.whiteQueenSide
      && this.gameState == other.gameState
      && this.lastEnPassantMove == other.lastEnPassantMove
      && this.isWhiteTurn == other.isWhiteTurn
      && this.halfMovesFromCoPM == other.halfMovesFromCoPM
      && this.totalFullMoves == other.totalFullMoves;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;

}



