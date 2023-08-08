import 'package:flutter/foundation.dart';
import 'package:game_template/screens/games/sudoku/models/sudoku_move.dart';
import 'package:game_template/services/extensions/iterable_extensions.dart';
import 'package:logging/logging.dart';
import 'sudoku_constants.dart';
import 'sudoku_cell.dart';
import '../logic/sudoku_logic.dart';
import 'sudoku_location.dart';

///LOWKEY MORE TO DO


enum SudokuGameState{
  win,
  error,
  none
}
class SudokuBoardState{
  Logger _logger = Logger("SudokuBoardState");
  List previousMoves;
  SudokuLocation? selectedLocation;
  List<SudokuCell> gameCells;
  SudokuGameState gameState;

  String get actualImport => SudokuImportAlgorithms().exportBoard(this);

  SudokuBoardState({
    required this.previousMoves,
    required this.gameCells,
    this.gameState = SudokuGameState.none,
    this.selectedLocation
  });

  SudokuBoardState.clone(SudokuBoardState sudokuBoardState):
    previousMoves = List.from(sudokuBoardState.previousMoves),
    gameCells = List.from(sudokuBoardState.gameCells),
    gameState = sudokuBoardState.gameState,
    selectedLocation = sudokuBoardState.selectedLocation == null ? null : SudokuLocation.clone(sudokuBoardState.selectedLocation!);

  SudokuBoardState getNewBoardFromMove(SudokuMove move){
    print(move);
    if(!move.changeMade) return this;
    SudokuBoardState newSudokuBoard = SudokuBoardState.clone(this);
    SudokuCell? from = newSudokuBoard.gameCells.firstWhere((element) {
      return element == move.from;
    });
    print("From: $from");
    if(from == null) return this;
    newSudokuBoard.gameCells[(from.sudokuLocation.row-1)*SudokuConstants().SUDOKU_SIZE_SQUARE + from.sudokuLocation.col - 1] = SudokuCell.clone(move.to);
    print(newSudokuBoard.gameCells[(from.sudokuLocation.row-1)*SudokuConstants().SUDOKU_SIZE_SQUARE + from.sudokuLocation.col - 1]);
    print(from);
    _logger.warning(this.toGridVisual());
    _logger.info(newSudokuBoard.toGridVisual());
    return newSudokuBoard;
  }

  @override
  String toString() {
    return {
      "gs": this.gameState.name,
      "gameCells": this.gameCells,
      "previousMoves?": this.previousMoves,
    }.toString();
  }

  String toGridVisual(){
    StringBuffer stringBuffer = StringBuffer();
    stringBuffer.writeln();
    for(int i = 0; i < SudokuConstants().SUDOKU_SIZE_SQUARE; i++){
      stringBuffer.writeln("-"*(SudokuConstants().SUDOKU_SIZE_SQUARE * 4 + 1));
      for(int j = 0; j < SudokuConstants().SUDOKU_SIZE_SQUARE; j++){
        stringBuffer.write("|");
        stringBuffer.write(" ${gameCells[i * SudokuConstants().SUDOKU_SIZE_SQUARE + j].value ?? " "} ");
        if(j == SudokuConstants().SUDOKU_SIZE_SQUARE-1){
          stringBuffer.writeln("|");
        }
      }

    }
    stringBuffer.writeln("-"*(SudokuConstants().SUDOKU_SIZE_SQUARE * 4 + 1));
    return stringBuffer.toString();
  }

  @override
  bool operator ==(Object other) {
    return other is SudokuBoardState
      && listEquals(previousMoves, other.previousMoves)
      && listEquals(gameCells, other.gameCells)
      && this.gameState == other.gameState;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => Object.hash(
    Object.hashAll(previousMoves),
    Object.hashAll(gameCells),
    gameState,
  );

}



