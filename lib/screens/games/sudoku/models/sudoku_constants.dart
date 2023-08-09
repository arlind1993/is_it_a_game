import 'dart:math';
class SudokuConstants{
  static SudokuConstants _chessConstants = SudokuConstants._();
  factory SudokuConstants(){
    return _chessConstants;
  }
  SudokuConstants._() {
    SUDOKU_SIZE_SQUARE = 9;
    SUDOKU_SIZE_SQUARE_GROUP = sqrt(SUDOKU_SIZE_SQUARE).ceil();
  }

  late final int SUDOKU_SIZE_SQUARE;
  late final int SUDOKU_SIZE_SQUARE_GROUP;
}

