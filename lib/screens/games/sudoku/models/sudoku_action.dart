import 'package:flutter/material.dart';

enum ActionTypes{
  number,
  bigType,
  extraType,
  mustType,
  saveControl,
  undoControl,
  redoControl,
  eraseControl,
  fillControl,
  hintControl,
  multipleControl,
}

class SudokuAction {
  static final int SUDOKUACTIONCOLS = 4;
  static final int SUDOKUACTIONROWS = 3;

  final Widget display;
  final ActionTypes actionType;
  final int? value;
  final int row;
  final int col;
  SudokuAction({
    required this.row,
    required this.col,
    required this.display,
    required this.actionType,
    this.value = null,
  }): assert(row == 0 || (col <= SUDOKUACTIONCOLS && row <= SUDOKUACTIONROWS));

}