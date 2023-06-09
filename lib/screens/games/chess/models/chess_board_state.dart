import 'package:flutter/foundation.dart';
import 'package:game_template/screens/games/chess/models/chess_possible_move_group.dart';
import 'package:logging/logging.dart';
import 'chess_constants.dart';
import 'chess_location.dart';
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
  Set<ChessPiece> deadChessPieces;
  int halfMovesFromCoPM;
  int totalFullMoves;
  ChessGameState gameState;

  String get actualFen => ChessFenAlgorithms().chessBoardToFen(this);
  List<ChessPiece> get aliveGamePieces => gamePiecesMapped.values.where((element) => !element.eaten).toList();
  Map<ChessLocation,ChessPiece> get aliveGamePiecesMapped => Map.fromEntries(gamePiecesMapped.entries.where((element) => !element.value.eaten));

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
  }): gamePiecesMapped = Map.fromEntries(gamePieces.where((element) => !element.eaten).map((e) => MapEntry(e.location, e))),
      deadChessPieces = Set.from(gamePieces.where((element) => element.eaten));

  ChessBoardState.clone(ChessBoardState chessBoardState):
    isWhiteTurn = chessBoardState.isWhiteTurn,
    blackQueenSide = chessBoardState.blackQueenSide,
    blackKingSide = chessBoardState.blackKingSide,
    whiteQueenSide = chessBoardState.whiteQueenSide,
    whiteKingSide = chessBoardState.whiteKingSide,
    lastEnPassantMove = chessBoardState.lastEnPassantMove == null
      ? null: ChessLocation.clone(chessBoardState.lastEnPassantMove!),
    gamePiecesMapped = Map.from(chessBoardState.gamePiecesMapped),
    deadChessPieces = Set.from(chessBoardState.deadChessPieces),
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
    newChessBoard.lastEnPassantMove = null;

    if(move.eatenPiece != null && newChessBoard.gamePiecesMapped[move.eatenPiece?.location] == move.eatenPiece){
      newChessBoard.halfMovesFromCoPM = 0;
      newChessBoard.deadChessPieces.add(newChessBoard.gamePiecesMapped[move.eatenPiece?.location]!);
      newChessBoard.gamePiecesMapped.remove(move.eatenPiece?.location);
    }
    if(move.kingSide || move.queenSide){
      ChessPiece kingOfMoveSide = newChessBoard.gamePiecesMapped.values.firstWhere((element) => !element.eaten
          && element.isWhite == move.pieceMovement.from.isWhite && element.pieceType == ChessPieceType.King
      );//if move was made from white -> white, black if black
      if (move.queenSide){//QueenSide
        ChessPiece queenSideRook = newChessBoard.gamePiecesMapped.values.firstWhere((element) => !element.eaten
            && element.isWhite == kingOfMoveSide.isWhite
            && element.pieceType == ChessPieceType.Rook
            && element.location.rank == kingOfMoveSide.location.rank
            && element.location.file < kingOfMoveSide.location.file
        );

        newChessBoard.gamePiecesMapped.remove(kingOfMoveSide.location);
        newChessBoard.gamePiecesMapped.remove(queenSideRook.location);
        newChessBoard.gamePiecesMapped.putIfAbsent(ChessLocation.clone(kingOfMoveSide.location)..file -= 2, () =>
          ChessPiece.clone(kingOfMoveSide)..location -= ChessLocation(rank: 0, file: 2));
        newChessBoard.gamePiecesMapped.putIfAbsent(ChessLocation.clone(queenSideRook.location)..file = kingOfMoveSide.location.file - 1, () =>
          ChessPiece.clone(queenSideRook)..location = ChessLocation(rank: kingOfMoveSide.location.rank, file: kingOfMoveSide.location.file - 1));
        if(move.pieceMovement.from.isWhite){
          newChessBoard.whiteKingSide = false;
          newChessBoard.whiteQueenSide = false;
        }else{
          newChessBoard.blackKingSide = false;
          newChessBoard.blackQueenSide = false;
        }

      }else if(move.kingSide){//KingSide
        ChessPiece kingSideRook = newChessBoard.gamePiecesMapped.values.firstWhere((element) => !element.eaten
            && element.isWhite == kingOfMoveSide.isWhite
            && element.pieceType == ChessPieceType.Rook
            && element.location.rank == kingOfMoveSide.location.rank
            && element.location.file > kingOfMoveSide.location.file
        );
        newChessBoard.gamePiecesMapped.remove(kingOfMoveSide.location);
        newChessBoard.gamePiecesMapped.remove(kingSideRook.location);

        newChessBoard.gamePiecesMapped.putIfAbsent(ChessLocation.clone(kingOfMoveSide.location)..file += 2, () =>
        ChessPiece.clone(kingOfMoveSide)..location += ChessLocation(rank: 0, file: 2));
        newChessBoard.gamePiecesMapped.putIfAbsent(ChessLocation.clone(kingSideRook.location)..file = kingOfMoveSide.location.file + 1, () =>
        ChessPiece.clone(kingSideRook)..location = ChessLocation(rank: kingOfMoveSide.location.rank, file: kingOfMoveSide.location.file + 1));
        if(move.pieceMovement.from.isWhite){
          newChessBoard.whiteKingSide = false;
          newChessBoard.whiteQueenSide = false;
        }else{
          newChessBoard.blackKingSide = false;
          newChessBoard.blackQueenSide = false;
        }
      }
    }else{
      newChessBoard.gamePiecesMapped = newChessBoard.gamePiecesMapped.map((key, value) {//Movement
        if (key == move.pieceMovement.from.location && value == move.pieceMovement.from
            && move.pieceMovement.from != move.pieceMovement.to) {
          if(move.pieceMovement.from.pieceType == ChessPieceType.Pawn){
            newChessBoard.halfMovesFromCoPM = 0;
            _logger.warning("Pawn: ${move.pieceMovement.from} -> ${move.pieceMovement.to}");
            if((move.pieceMovement.from.location - move.pieceMovement.to.location).rank.abs() == 2){//Double pawn push
              if(move.pieceMovement.from.isWhite){
                newChessBoard.lastEnPassantMove = move.pieceMovement.to.location - ChessLocation(rank: 1, file: 0);
              }else{
                newChessBoard.lastEnPassantMove = move.pieceMovement.to.location + ChessLocation(rank: 1, file: 0);
              }
              _logger.warning("En Passant: ${newChessBoard.lastEnPassantMove}");
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
                newChessBoard.blackKingSide = false;
                newChessBoard.blackQueenSide = false;
              }
            }
          }
          return MapEntry(move.pieceMovement.to.location, move.pieceMovement.to);
        }
        return MapEntry(key, value);//No Change
      });
    }
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

  String toGridVisual(){
    StringBuffer stringBuffer = StringBuffer();
    stringBuffer.writeln();
    for(int i = 0; i < ChessConstants().CHESS_SIZE_SQUARE; i++){
      stringBuffer.writeln("-"*(ChessConstants().CHESS_SIZE_SQUARE * 4 + 1));
      for(int j = 0; j < ChessConstants().CHESS_SIZE_SQUARE; j++){
        stringBuffer.write("|");
        stringBuffer.write(" ${gamePiecesMapped[ChessLocation(rank: ChessConstants().CHESS_SIZE_SQUARE-i, file: j+1)]?.pieceCodeColor ?? " "} ");
        if(j == ChessConstants().CHESS_SIZE_SQUARE-1){
          stringBuffer.writeln("|");
        }
      }

    }
    stringBuffer.writeln("-"*(ChessConstants().CHESS_SIZE_SQUARE * 4 + 1));
    return stringBuffer.toString();
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



