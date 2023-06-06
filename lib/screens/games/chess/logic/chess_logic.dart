

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import '../chess_constants.dart';
import 'chess_piece_logic.dart';
import 'chess_fen_logic.dart';



class ChessBoardState{
  Logger _logger = Logger("ChessBoardState");
  bool isWhiteTurn;
  bool blackQueenSide;
  bool blackKingSide;
  bool whiteQueenSide;
  bool whiteKingSide;
  ChessLocation? lastEnPassantMove;
  List<ChessPiece> gamePieces;
  int halfMovesFromCoPM;
  int totalFullMoves;
  ChessGameState gameState;

  String get actualFen => ChessFenAlgorithms().chessBoardToFen(this);
  List<ChessPiece> get aliveGamePieces => gamePieces.where((element) => !element.eaten).toList();
  List<ChessPiece> get deadGamePieces => gamePieces.where((element) => element.eaten).toList();

  ChessBoardState({
    required this.isWhiteTurn,
    required this.blackQueenSide,
    required this.blackKingSide,
    required this.whiteQueenSide,
    required this.whiteKingSide,
    this.lastEnPassantMove,
    required this.gamePieces,
    required this.halfMovesFromCoPM,
    required this.totalFullMoves,
    this.gameState = ChessGameState.None,
  });



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



