import 'package:logging/logging.dart';

class SudokuPossibleMovesAlgorithms{
  static SudokuPossibleMovesAlgorithms _possibleMovesAlgorithms = SudokuPossibleMovesAlgorithms._();
  factory SudokuPossibleMovesAlgorithms(){
    return _possibleMovesAlgorithms;
  }
  SudokuPossibleMovesAlgorithms._();

  Logger _logger = Logger("Possible Moves");

}


