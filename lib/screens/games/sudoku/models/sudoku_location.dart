import 'sudoku_constants.dart';

class SudokuLocation{
  int row;
  int col;

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
