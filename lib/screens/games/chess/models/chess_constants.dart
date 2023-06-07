import 'package:flutter_svg/flutter_svg.dart';
///LOWKEY DONE
enum ChessGameState{
  WhiteWin,
  BlackWin,
  Draw,
  None,
}

enum ChessPieceType{
  Pawn,
  Bishop,
  Knight,
  Rook,
  Queen,
  King,
}

class ChessConstants{
  static ChessConstants _chessConstants = ChessConstants._();
  factory ChessConstants(){
    return _chessConstants;
  }
  ChessConstants._();

  final int CHESS_SIZE_SQUARE = 8;
  
  Map<String, SvgPicture> chessPiecePictures = {
    "b": SvgPicture.asset("assets/images/chess/black_bishop.svg"),
    "k": SvgPicture.asset("assets/images/chess/black_king.svg"),
    "n": SvgPicture.asset("assets/images/chess/black_knight.svg"),
    "p": SvgPicture.asset("assets/images/chess/black_pawn.svg"),
    "q": SvgPicture.asset("assets/images/chess/black_queen.svg"),
    "r": SvgPicture.asset("assets/images/chess/black_rook.svg"),
    "B": SvgPicture.asset("assets/images/chess/white_bishop.svg"),
    "K": SvgPicture.asset("assets/images/chess/white_king.svg"),
    "N": SvgPicture.asset("assets/images/chess/white_knight.svg"),
    "P": SvgPicture.asset("assets/images/chess/white_pawn.svg"),
    "Q": SvgPicture.asset("assets/images/chess/white_queen.svg"),
    "R": SvgPicture.asset("assets/images/chess/white_rook.svg"),
  };
}

