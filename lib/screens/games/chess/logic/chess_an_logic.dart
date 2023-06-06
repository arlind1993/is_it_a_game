import 'package:game_template/screens/games/chess/logic/chess_logic.dart';
import 'chess_piece_logic.dart';



class ChessANAlgorithms{
  static ChessANAlgorithms _algorithms = ChessANAlgorithms._();
  factory ChessANAlgorithms(){
    return _algorithms;
  }
  ChessANAlgorithms._();

  String getLastAlgebraicNotation(ChessBoardState previousState, ChessBoardState currentState){
    int pieceGain = currentState.gamePieces.length - previousState.gamePieces.length;
    bool pieceEaten = false;
    if(pieceGain == -1){
      pieceEaten = true;
    }else if(pieceGain != 0){
      throw "To many game pieces eaten or a game piece appeared out of nowhere";
    }

    (String, String) a = ("","");
    a.$1 =  "2";

    for(ChessPiece currentPiece in currentState.gamePieces){
      for(ChessPiece previousPiece in previousState.gamePieces){

      }
    }

    ///TODO: GET ALL SQUARES THAT ARE DIFFERENT

    return "";
  }

  ChessBoardState makeMoveWith(ChessBoardState chessBoardState, String algebraicNotation){
    return "";
  }
}