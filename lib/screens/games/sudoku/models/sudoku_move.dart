import 'package:game_template/screens/games/sudoku/models/sudoku_cell.dart';

class SudokuMove{
  SudokuCell from;
  SudokuCell to;

  bool get changeMade => from != to;
  SudokuMove({
    required this.from,
    required this.to,
  }): assert(from.sudokuLocation == to.sudokuLocation);

  @override
  String toString() {
    return "$from <==>> $to";
  }
}