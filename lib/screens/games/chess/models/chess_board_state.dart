import 'package:flutter/foundation.dart';
import 'package:game_template/screens/games/chess/models/chess_possible_move_group.dart';
import 'package:logging/logging.dart';
import 'chess_constants.dart';
import 'chess_location.dart';
import 'chess_movement.dart';
import 'chess_piece.dart';
import '../logic/chess_fen_logic.dart';

///LOWKEY MORE TO DO

class ChessBoardState{
  Logger _logger = Logger("ChessBoardState");
  bool isWhiteTurn;
  bool blackQueenSide;
  bool blackKingSide;
  bool whiteQueenSide;
  bool whiteKingSide;
  ChessLocation? lastEnPassantMove;
  Map<ChessLocation,ChessPiece> gamePiecesMapped;
  int halfMovesFromCoPM;
  int totalFullMoves;
  ChessGameState gameState;

  String get actualFen => ChessFenAlgorithms().chessBoardToFen(this);
  List<ChessPiece> get aliveGamePieces => gamePiecesMapped.values.where((element) => !element.eaten).toList();
  List<ChessPiece> get deadGamePieces => gamePiecesMapped.values.where((element) => element.eaten).toList();
  Map<ChessLocation,ChessPiece> get aliveGamePiecesMapped => Map.fromEntries(gamePiecesMapped.entries.where((element) => !element.value.eaten));
  Map<ChessLocation,ChessPiece> get deadGamePiecesMapped => Map.fromEntries(gamePiecesMapped.entries.where((element) => element.value.eaten));

  ChessBoardState({
    required this.isWhiteTurn,
    required this.blackQueenSide,
    required this.blackKingSide,
    required this.whiteQueenSide,
    required this.whiteKingSide,
    this.lastEnPassantMove,
    required List gamePieces,
    required this.halfMovesFromCoPM,
    required this.totalFullMoves,
    this.gameState = ChessGameState.None,
  }): gamePiecesMapped = {}..addEntries(gamePieces.where((element) => !element.eaten).map((e) => MapEntry(e.location, e)));

  ChessBoardState.clone(ChessBoardState chessBoardState):
    isWhiteTurn = chessBoardState.isWhiteTurn,
    blackQueenSide = chessBoardState.blackQueenSide,
    blackKingSide = chessBoardState.blackKingSide,
    whiteQueenSide = chessBoardState.whiteQueenSide,
    whiteKingSide = chessBoardState.whiteKingSide,
    lastEnPassantMove = chessBoardState.lastEnPassantMove,
    gamePiecesMapped = chessBoardState.gamePiecesMapped,
    halfMovesFromCoPM = chessBoardState.halfMovesFromCoPM,
    totalFullMoves = chessBoardState.totalFullMoves,
    gameState = chessBoardState.gameState;

  ChessBoardState getNewBoardFromMove(PossibleMoveGroup move){
    if(!move.changeMade) return this;
    ChessBoardState newChessBoard = ChessBoardState.clone(this);
    newChessBoard.isWhiteTurn = !newChessBoard.isWhiteTurn;
    newChessBoard.halfMovesFromCoPM += 1;
    if(!newChessBoard.isWhiteTurn){
      newChessBoard.totalFullMoves += 1;
    }
    lastEnPassantMove = null;
    newChessBoard.gamePiecesMapped = newChessBoard.gamePiecesMapped.map((key, value) {
      if (key == move.pieceMovement.from.location && value == move.pieceMovement.from
        && move.pieceMovement.from != move.pieceMovement.to) {//Movement
        if(move.pieceMovement.from.pieceType == ChessPieceType.Pawn){
          newChessBoard.halfMovesFromCoPM = 0;
          if((move.pieceMovement.from.location - move.pieceMovement.to.location).rank.abs() == 2){//Double pawn push
            lastEnPassantMove = move.pieceMovement.to.location;
          }
        }else if(move.pieceMovement.from.pieceType == ChessPieceType.Rook){
          bool castlingStillPossible = true;
          if(move.pieceMovement.from.isWhite){
            if(!newChessBoard.whiteKingSide && !newChessBoard.whiteQueenSide){
              castlingStillPossible = false;
            }
          }else{
            if(!newChessBoard.blackKingSide && !newChessBoard.blackQueenSide){
              castlingStillPossible = false;
            }
          }
          if(castlingStillPossible){
            ChessPiece king = newChessBoard.gamePiecesMapped.values.firstWhere((element) => !element.eaten
                && element.isWhite == move.pieceMovement.from.isWhite && element.pieceType == ChessPieceType.King
            );
            if(move.pieceMovement.from.location.file < king.location.file){
              if(move.pieceMovement.from.isWhite) {
                newChessBoard.whiteQueenSide = false;
              }else{
                newChessBoard.blackQueenSide = false;
              }
            }else{
              if(move.pieceMovement.from.isWhite) {
                newChessBoard.whiteKingSide = false;
              }else{
                newChessBoard.blackKingSide = false;
              }
            }
          }
        }else if(move.pieceMovement.from.pieceType == ChessPieceType.King){
          bool castlingStillPossible = true;
          if(move.pieceMovement.from.isWhite){
            if(!newChessBoard.whiteKingSide && !newChessBoard.whiteQueenSide){
              castlingStillPossible = false;
            }
          }else{
            if(!newChessBoard.blackKingSide && !newChessBoard.blackQueenSide){
              castlingStillPossible = false;
            }
          }
          if(castlingStillPossible){
            if(move.pieceMovement.from.isWhite){
              newChessBoard.whiteKingSide = false;
              newChessBoard.whiteQueenSide = false;
            }else{
              newChessBoard.whiteKingSide = false;
              newChessBoard.whiteQueenSide = false;
            }
          }
        }
        return MapEntry(move.pieceMovement.to.location, move.pieceMovement.to);
      }
      if(move.eatenPiece != null && key == move.eatenPiece?.location && value == move.eatenPiece){//Eaten Piece
        newChessBoard.halfMovesFromCoPM = 0;
        return MapEntry(key, value..eaten = true);
      }
      if(move.queenSide){//KingSide
        if(key == move.pieceMovement.from.location && value == move.pieceMovement.from){//The King
          return MapEntry(key..file -= 2, value..location -= ChessLocation(rank: 0, file: 2));
        }
        if(value.isWhite == move.pieceMovement.from.isWhite
          && value.pieceType == ChessPieceType.Rook
          && value.eaten == false
          && value.location.rank == move.pieceMovement.from.location.rank
          && value.location.file < move.pieceMovement.from.location.file
        ){//The Rook
          return MapEntry(key..file -= 1, value..location -= ChessLocation(rank: 0, file: 1));
        }
      }
      if(move.queenSide){//QueenSide
        if(key == move.pieceMovement.from.location && value == move.pieceMovement.from){//The King
          return MapEntry(key..file += 2, value..location += ChessLocation(rank: 0, file: 2));
        }
        if(value.isWhite == move.pieceMovement.from.isWhite
            && value.pieceType == ChessPieceType.Rook
            && value.eaten == false
            && value.location.rank == move.pieceMovement.from.location.rank
            && value.location.file < move.pieceMovement.from.location.file
        ){//The Rook
          return MapEntry(key..file += 1, value..location += ChessLocation(rank: 0, file: 1));
        }
      }
      return MapEntry(key, value);//No Change
    });


    return newChessBoard;
  }

  @override
  String toString() {
    return {
      "gs": this.gameState.name,
      "pieces": this.gamePiecesMapped.values,
      "enPass?": this.lastEnPassantMove,
      "turn":this.isWhiteTurn ? "white": "black",
      "fen":this.actualFen
    }.toString();
  }

  @override
  bool operator ==(Object other) {
    return other is ChessBoardState
      && mapEquals(gamePiecesMapped, other.gamePiecesMapped)
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



