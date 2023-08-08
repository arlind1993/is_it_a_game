import 'package:flutter_svg/flutter_svg.dart';

class SudokuConstants{
  static SudokuConstants _chessConstants = SudokuConstants._();
  factory SudokuConstants(){
    return _chessConstants;
  }
  SudokuConstants._();

  final int SUDOKU_SIZE_SQUARE = 9;

}

