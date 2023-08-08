import 'package:game_template/screens/games/chess/models/chess_constants.dart';
import 'package:game_template/screens/games/sudoku/models/sudoku_location.dart';
import 'package:logging/logging.dart';

import '../models/sudoku_board_state.dart';
import '../models/sudoku_constants.dart';
import '../models/sudoku_cell.dart';
///LOWKEY DONE
class SudokuImportAlgorithms{
  static const String defaultStartingFen = "v";
  static SudokuImportAlgorithms _fenAlgorithms = SudokuImportAlgorithms._();
  factory SudokuImportAlgorithms(){
    return _fenAlgorithms;
  }
  SudokuImportAlgorithms._();
  Logger _logger = Logger("FenAlgorithms");

  SudokuBoardState importBoard(String importString){
    if(importString.length == SudokuConstants().SUDOKU_SIZE_SQUARE * SudokuConstants().SUDOKU_SIZE_SQUARE){
      List<SudokuCell> pieces = [];

      for(int i = 0 ; i < importString.length; i++){
        int row = (i ~/ SudokuConstants().SUDOKU_SIZE_SQUARE) + 1;
        int col = (i % SudokuConstants().SUDOKU_SIZE_SQUARE) + 1;
        // assert(importString[i].contains(RegExp("(.|[0-9])")));
        int? value;
        SudokuCellType cellType = SudokuCellType.mutable;
        switch(importString[i]){
          case "1" : value = 1; cellType = SudokuCellType.initial; break;
          case "2" : value = 2; cellType = SudokuCellType.initial; break;
          case "3" : value = 3; cellType = SudokuCellType.initial; break;
          case "4" : value = 4; cellType = SudokuCellType.initial; break;
          case "5" : value = 5; cellType = SudokuCellType.initial; break;
          case "6" : value = 6; cellType = SudokuCellType.initial; break;
          case "7" : value = 7; cellType = SudokuCellType.initial; break;
          case "8" : value = 8; cellType = SudokuCellType.initial; break;
          case "9" : value = 9; cellType = SudokuCellType.initial; break;
        }
        pieces.add(SudokuCell(sudokuLocation: SudokuLocation(row: row, col: col), value: value, type: cellType));
      }
      return SudokuBoardState(previousMoves: [], gameCells: pieces);
    }else{
      throw "input is of length => ${importString.length}!";
    }
  }



  String exportBoard(SudokuBoardState chessBoardState){
    StringBuffer bufferResult = StringBuffer();
    for(int i = 0; i < chessBoardState.gameCells.length ; i++){
      if(chessBoardState.gameCells[i].value!=null){
        bufferResult.write(String.fromCharCode(48 + chessBoardState.gameCells[i].value!));
      }
    }
    return bufferResult.toString();
  }

}