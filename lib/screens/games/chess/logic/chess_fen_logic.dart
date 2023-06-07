import 'package:game_template/screens/games/chess/models/chess_board_state.dart';
import 'package:game_template/screens/games/chess/models/chess_piece.dart';
import 'package:logging/logging.dart';

import '../models/chess_constants.dart';
import '../models/chess_location.dart';
///LOWKEY DONE
class ChessFenAlgorithms{
  static const String defaultStartingFen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";
  static ChessFenAlgorithms _fenAlgorithms = ChessFenAlgorithms._();
  factory ChessFenAlgorithms(){
    return _fenAlgorithms;
  }
  ChessFenAlgorithms._();
  Logger _logger = Logger("FenAlgorithms");

  ChessBoardState fenToBoard(String fen){
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
      
      return ChessBoardState(
        isWhiteTurn: nextPlayerMove == "w",
        whiteKingSide: castlingRights.contains("K"),
        whiteQueenSide: castlingRights.contains("Q"), 
        blackKingSide: castlingRights.contains("k"),
        blackQueenSide: castlingRights.contains("q"),
        halfMovesFromCoPM : int.parse(halfMove),
        totalFullMoves : int.parse(fullMove),
        lastEnPassantMove : enPassantPlayed == "-" ? null : ChessLocation.fromPieceFen(enPassantPlayed),
        gamePieces: fenPieceParser(piecePlacement)
      );
    }else{
      throw "fan input is not correct is it doesn't feature all 6 rules";
    }
  }


  List<ChessPiece> fenPieceParser(String fenPieces){
    List<String> fenPieceInRanks = fenPieces.split("/");
    List<ChessPiece> pieces = [];
    if(fenPieceInRanks.length == ChessConstants().CHESS_SIZE_SQUARE){
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
      return pieces;
    }else{
      throw "fan piece input is not correct or it doesn't feature 8 ranks";
    }
  }

  String chessBoardToFen(ChessBoardState chessBoardState){
    StringBuffer bufferResult = StringBuffer();

    for(int i = 0; i < ChessConstants().CHESS_SIZE_SQUARE ; i++){
      List<ChessPiece> listPieces = chessBoardState.gamePiecesMapped.values.where((element) {
        return !element.eaten && element.location.rank == ChessConstants().CHESS_SIZE_SQUARE-i;
      }).toList();

      int numToAdd = 0;
      for(int j = 0; j < ChessConstants().CHESS_SIZE_SQUARE; j++){
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
      if(i!=ChessConstants().CHESS_SIZE_SQUARE-1){
        bufferResult.write("/");
      }
    }
    bufferResult.write(" ");
    bufferResult.write(chessBoardState.isWhiteTurn ? "w" : "b");
    bufferResult.write(" ");
    if(chessBoardState.whiteKingSide
        || chessBoardState.whiteQueenSide
        || chessBoardState.blackKingSide
        || chessBoardState.blackQueenSide){
      bufferResult
        ..write(chessBoardState.whiteKingSide?"K":"")
        ..write(chessBoardState.whiteQueenSide?"Q":"")
        ..write(chessBoardState.blackKingSide?"k":"")
        ..write(chessBoardState.blackQueenSide?"q":"");
    }else{
      bufferResult.write("-");
    }
    bufferResult.write(" ");
    if(chessBoardState.lastEnPassantMove == null || chessBoardState.lastEnPassantMove?.inside == true) {
      bufferResult.write("-");
    }else{
      bufferResult.write(chessBoardState.lastEnPassantMove!.nameConvention);
    }
    bufferResult.write(" ");
    bufferResult.write("${chessBoardState.halfMovesFromCoPM}");
    bufferResult.write(" ");
    bufferResult.write("${chessBoardState.totalFullMoves}");

    return bufferResult.toString();
  }

}