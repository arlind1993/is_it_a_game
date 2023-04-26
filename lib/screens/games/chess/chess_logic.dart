
class ChessLogic{
  final String defaultStartingFen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";
  ChessLogic(){
    fenParser(defaultStartingFen);
  }
  fenParser(String fen){
    List<String> rules = fen.split(" ");
    if(rules.length == 6){
      String piecePlacement = fen[0];
      String nextPlayerMove = fen[1];
      String castlingRights = fen[2];
      String enPassantPlayed = fen[3];
      String halfMove = fen[4];
      String fullMove = fen[5];
    }else{
      throw "fan input is not correct is it doesn't feature all 6 rules";
    }
  }

  fenPieceParser(String fenPieces){
    List<String> fenPieceInRanks = fenPieces.split("/");
    if(fenPieceInRanks.length == 8){

    }else{
      throw "fan Piece input is not correct or it doesn't feature 8 ranks";
    }
  }

}

