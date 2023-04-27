import 'package:game_template/screens/games/chess/piece_logic.dart';

class GameState{
  late bool isWhiteTurn;
  late bool blackQueenSide;
  late bool blackKingSide;
  late bool whiteQueenSide;
  late bool whiteKingSide;
  Piece? lastEnPassantMove;
  List<Piece> gamePieces = [];
  late int halfMovesFromCoPM;
  late int totalFullMoves;

  bool inCheckWhite = false;
  bool inCheckBlack = false;

  final String defaultStartingFen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";
  ChessLogic(){
    fenParser(defaultStartingFen, initialise: true);
  }
  fenParser(String fen,{bool initialise = false}){
    List<String> rules = fen.split(" ");
    if(rules.length == 6){
      String piecePlacement = fen[0];
      String nextPlayerMove = fen[1];
      assert(nextPlayerMove == "w" || nextPlayerMove == "b" );
      String castlingRights = fen[2];
      assert(castlingRights.contains(RegExp("(k|q|K|q|-)")));
      String enPassantPlayed = fen[3];
      assert(enPassantPlayed.contains(RegExp("([a-h][0-8]|-)")));
      String halfMove = fen[4];
      assert(int.tryParse(halfMove)!=null);
      String fullMove = fen[5];
      assert(int.tryParse(fullMove)!=null);

      if(initialise){
        isWhiteTurn = nextPlayerMove == "w";
        whiteKingSide = castlingRights.contains("K");
        whiteQueenSide = castlingRights.contains("Q");
        blackKingSide = castlingRights.contains("k");
        blackQueenSide = castlingRights.contains("q");
        halfMovesFromCoPM = int.parse(halfMove);
        totalFullMoves = int.parse(fullMove);
      }
      fenPieceParser(piecePlacement, initialise: initialise);
    }else{
      throw "fan input is not correct is it doesn't feature all 6 rules";
    }
  }

  fenPieceParser(String fenPieces, {bool initialise = false}){
    List<String> fenPieceInRanks = fenPieces.split("/");
    List<Piece> pieces = [];
    if(fenPieceInRanks.length == 8){
      int rank = 1;
      for(int i = 0 ; i < fenPieceInRanks.length; i++){
        rank = i+1;
        int file = 1;
        for(int j = 0; j < fenPieceInRanks[i].length; j++) {
          assert(fenPieceInRanks[i][j].contains("(r|b|n|k|q|p|R|B|N|K|Q|P|[0-8])"));
          int? emptySpaces = int.tryParse(fenPieceInRanks[i][j]);
          if(emptySpaces == null){
            bool isWhite = fenPieceInRanks[i][j].toUpperCase() == fenPieceInRanks[i][j] && fenPieceInRanks[i][j].isNotEmpty;
            switch(fenPieceInRanks[i][j].toUpperCase()){
              case "R":
                pieces.add(Rook(location: Location(rank: rank, file:  file), isWhite: isWhite));
                file++;
                break;
              case "B":
                pieces.add(Bishop(location: Location(rank: rank, file:  file), isWhite: isWhite));
                file++;
                break;
              case "N":
                pieces.add(Knight(location: Location(rank: rank, file:  file), isWhite: isWhite));
                file++;
                break;
              case "K":
                pieces.add(King(location: Location(rank: rank, file:  file), isWhite: isWhite));
                file++;
                break;
              case "Q":
                pieces.add(Queen(location: Location(rank: rank, file:  file), isWhite: isWhite));
                file++;
                break;
              case "P":
                pieces.add(Pawn(location: Location(rank: rank, file:  file), isWhite: isWhite));
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
    }else{
      throw "fan Piece input is not correct or it doesn't feature 8 ranks";
    }
  }
  toFen(){

  }
}



