import 'package:logging/logging.dart';
import '../models/chess_location.dart';
import '../models/chess_movement.dart';
import '../models/chess_piece.dart';
import '../models/chess_board_state.dart';

/// HIGHKEY A LOT TO DO
class ChessANAlgorithms{
  static ChessANAlgorithms _algorithms = ChessANAlgorithms._();
  factory ChessANAlgorithms(){
    return _algorithms;
  }
  ChessANAlgorithms._();
  Logger _logger = Logger("ChessANAlgorithms");

  String getLastAlgebraicNotation(ChessBoardState previousState, ChessBoardState currentState){
    int pieceGain = currentState.gamePiecesMapped.length - previousState.gamePiecesMapped.length;
    bool pieceEaten = false;
    if(pieceGain == -1){
      pieceEaten = true;
    }else if(pieceGain != 0){
      throw "To many game pieces eaten or a game piece appeared out of nowhere";
    }

    List<ChessMovement> currentPiecesChanged = [];

    for(MapEntry<ChessLocation,ChessPiece> previousPiece in previousState.gamePiecesMapped.entries){
      ChessPiece prev = previousPiece.value;
      ChessPiece curr = currentState.gamePiecesMapped[previousPiece.key] ?? ChessPiece.clone(prev)..eaten = true;
      if(prev != curr){
        currentPiecesChanged.add(ChessMovement(from: prev, to: curr));
      }
    }

    if(currentPiecesChanged.length == 0){
      throw "No movement observed";
    }else if(currentPiecesChanged.length > 3){
      _logger.warning("Wierd af case so many movements ${currentPiecesChanged}");
    }else{

    }

    return "";
  }

  ChessBoardState? makeMoveWith(ChessBoardState chessBoardState, String algebraicNotation){
    // return ChessBoardState(
    //     isWhiteTurn: isWhiteTurn,
    //     blackQueenSide: blackQueenSide,
    //     blackKingSide: blackKingSide,
    //     whiteQueenSide: whiteQueenSide,
    //     whiteKingSide: whiteKingSide,
    //     gamePieces: gamePieces,
    //     halfMovesFromCoPM: halfMovesFromCoPM,
    //     totalFullMoves: totalFullMoves
    // );
  }
}