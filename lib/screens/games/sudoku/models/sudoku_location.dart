import 'sudoku_constants.dart';

class SudokuLocation{
  int row;
  int col;

  int get grid => (row - 1) ~/ SudokuConstants().SUDOKU_SIZE_SQUARE_GROUP
      * SudokuConstants().SUDOKU_SIZE_SQUARE_GROUP +
      (col - 1) ~/ SudokuConstants().SUDOKU_SIZE_SQUARE_GROUP + 1;
  bool get inside => (row >= 1 && row <= SudokuConstants().SUDOKU_SIZE_SQUARE) && (col >= 1 && col <= SudokuConstants().SUDOKU_SIZE_SQUARE);
  String get nameConvention => String.fromCharCode(96 + col) + String.fromCharCode(48 + row);
  SudokuLocation({
    required this.row,
    required this.col
  });

  SudokuLocation.clone(SudokuLocation location):
    row = location.row,
    col = location.col;

  bool operator == (o) => o is SudokuLocation
      && o.row == row
      && o.col == col;

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() {
    return nameConvention;
  }
}
