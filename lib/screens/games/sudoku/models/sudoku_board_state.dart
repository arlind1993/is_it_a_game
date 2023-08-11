import 'package:flutter/foundation.dart';
import 'package:game_template/screens/games/sudoku/models/sudoku_move.dart';
import 'package:game_template/services/data_structures.dart';
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
  StackDS<SudokuMove> previousMoves;
  StackDS<SudokuMove> redoMoves;
  SudokuLocation? selectedLocation;
  int? highlightedValue;
  List<SudokuCell> gameCells;
  SudokuGameState gameState;

  List<SudokuCell> get onlyErrorsInCells{
    List<SudokuCell> result = [];
    for(SudokuCell cell in gameCells){
      SudokuCell sudoku = SudokuCell(sudokuLocation: SudokuLocation.clone(cell.sudokuLocation), value: null, type: cell.type,);
      if(cell.type == SudokuCellType.mutable){
        for(SudokuCell cellOther in gameCells){
          if(cell == cellOther) continue;
          if(cellOther.value == null) continue;
          if(cell.sudokuLocation.row == cellOther.sudokuLocation.row
              || cell.sudokuLocation.col == cellOther.sudokuLocation.col
              || cell.sudokuLocation.grid == cellOther.sudokuLocation.grid){
            if(sudoku.value == null && cell.value == cellOther.value){
              sudoku.value = cellOther.value;
            }
            if(!sudoku.listMust.contains(cellOther.value) && cell.listMust.contains(cellOther.value!)){
              sudoku.addOrRemoveMust([cellOther.value!]);
            }
            if(!sudoku.listExtra.contains(cellOther.value) && cell.listExtra.contains(cellOther.value!)){
              sudoku.addOrRemoveExtra([cellOther.value!]);
            }
          }
        }
      }
      result.add(sudoku);
    }
    return result;
  }

  String get actualImport => SudokuImportAlgorithms().exportBoard(this);

  SudokuBoardState({
    List<SudokuMove> previousMoves = const [],
    List<SudokuMove> redoMoves = const [],
    required this.gameCells,
    this.gameState = SudokuGameState.none,
    this.selectedLocation,
    this.highlightedValue,
  }): this.redoMoves = StackDS.of(redoMoves),
    this.previousMoves = StackDS.of(previousMoves);

  SudokuBoardState.clone(SudokuBoardState sudokuBoardState):
    redoMoves = StackDS.of(sudokuBoardState.redoMoves.elementsCopied),
    previousMoves = StackDS.of(sudokuBoardState.previousMoves.elementsCopied),
    gameCells = List.from(sudokuBoardState.gameCells),
    gameState = sudokuBoardState.gameState,
    selectedLocation = sudokuBoardState.selectedLocation == null ? null : SudokuLocation.clone(sudokuBoardState.selectedLocation!),
    highlightedValue = sudokuBoardState.highlightedValue;

  bool makeMove(SudokuMove move){
    print(move);
    if(!move.changeMade) return false;
    SudokuCell? from = gameCells.firstWhereIfThere((element) {
      return element == move.from;
    });
    // print("From: $from");
    if(from == null) return false;
    gameCells[(from.sudokuLocation.row-1)*SudokuConstants().SUDOKU_SIZE_SQUARE + from.sudokuLocation.col - 1] = SudokuCell.clone(move.to);
    redoMoves.clear();
    previousMoves.push(move);
    return true;
  }

  bool undo(){
    if(previousMoves.isEmpty) return false;
    SudokuCell? from = gameCells.firstWhereIfThere((element) {
      return element == previousMoves.peek.to;
    });
    print("From: $from");
    if(from == null) return false;
    selectedLocation = SudokuLocation.clone(from.sudokuLocation);
    gameCells[(from.sudokuLocation.row-1)*SudokuConstants().SUDOKU_SIZE_SQUARE + from.sudokuLocation.col - 1] = SudokuCell.clone(previousMoves.peek.from);
    redoMoves.push(previousMoves.peek);
    previousMoves.pop();
    return true;
  }

  bool redo(){
    if(redoMoves.isEmpty) return false;
    SudokuCell? from = gameCells.firstWhereIfThere((element) {
      return element == redoMoves.peek.from;
    });
    print("From: $from");
    if(from == null) return false;
    selectedLocation = SudokuLocation.clone(from.sudokuLocation);
    gameCells[(from.sudokuLocation.row-1)*SudokuConstants().SUDOKU_SIZE_SQUARE + from.sudokuLocation.col - 1] = SudokuCell.clone(redoMoves.peek.to);
    previousMoves.push(redoMoves.peek);
    redoMoves.pop();
    return true;
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
        if(selectedLocation?.row == i + 1 && selectedLocation?.col == j + 1){
          stringBuffer.write("+${gameCells[i * SudokuConstants().SUDOKU_SIZE_SQUARE + j].value ?? " "}+");
        }else{
          stringBuffer.write(" ${gameCells[i * SudokuConstants().SUDOKU_SIZE_SQUARE + j].value ?? " "} ");
        }
        if(j == SudokuConstants().SUDOKU_SIZE_SQUARE-1){
          stringBuffer.writeln("|");
        }
      }
    }
    stringBuffer.write("-"*(SudokuConstants().SUDOKU_SIZE_SQUARE * 4 + 1));
    return stringBuffer.toString();
  }

  @override
  bool operator ==(Object other) {
    return other is SudokuBoardState
      && listEquals(previousMoves.elementsCopied, other.previousMoves.elementsCopied)
      && listEquals(redoMoves.elementsCopied, other.redoMoves.elementsCopied)
      && listEquals(gameCells, other.gameCells)
      && this.gameState == other.gameState
      && this.selectedLocation == other.selectedLocation
      && this.highlightedValue == other.highlightedValue;
  }

  @override
  int get hashCode => Object.hash(
    previousMoves,
    redoMoves,
    Object.hashAll(gameCells),
    gameState,
    selectedLocation,
    highlightedValue
  );

}



