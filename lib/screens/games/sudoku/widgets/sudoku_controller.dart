import 'package:flutter/material.dart';
import 'package:game_template/screens/games/sudoku/models/sudoku_action.dart';
import 'package:game_template/screens/games/sudoku/models/sudoku_board_state.dart';
import 'package:game_template/screens/games/sudoku/models/sudoku_cell.dart';
import 'package:game_template/screens/games/sudoku/models/sudoku_constants.dart';
import 'package:game_template/screens/games/sudoku/models/sudoku_move.dart';
import 'package:game_template/services/app_styles/app_color.dart';
import 'package:game_template/services/extensions/iterable_extensions.dart';
import 'package:game_template/widgets/text_widget.dart';

import '../../../../services/get_it_helper.dart';
import '../models/sudoku_location.dart';

class SudokuControllerGroup{
  List<SudokuAction> actionsGrouped;
  ValueNotifier<SudokuAction?> actionSelected;
  SudokuControllerGroup({
    required this.actionsGrouped,
    SudokuAction? actionSelectedValue,
  }): actionSelected = ValueNotifier(actionSelectedValue);
}

class SudokuController extends StatefulWidget {

  late List<SudokuAction> actions;
  late SudokuControllerGroup numberGroup;
  late SudokuControllerGroup noteTypeGroup;
  late SudokuControllerGroup controllerGroup;
  late SudokuControllerGroup multipleControlGroup;
  ValueNotifier<SudokuBoardState> actualBoard;

  SudokuController({
    super.key,
    required this.actualBoard,
  }) {
    actions = [
      SudokuAction(row: 1, col: 1, display: TextWidget(text: '1'), actionType: ActionTypes.number, value: 1),
      SudokuAction(row: 1, col: 2, display: TextWidget(text: '2'), actionType: ActionTypes.number, value: 2),
      SudokuAction(row: 1, col: 3, display: TextWidget(text: '3'), actionType: ActionTypes.number, value: 3),
      SudokuAction(row: 2, col: 1, display: TextWidget(text: '4'), actionType: ActionTypes.number, value: 4),
      SudokuAction(row: 2, col: 2, display: TextWidget(text: '5'), actionType: ActionTypes.number, value: 5),
      SudokuAction(row: 2, col: 3, display: TextWidget(text: '6'), actionType: ActionTypes.number, value: 6),
      SudokuAction(row: 3, col: 1, display: TextWidget(text: '7'), actionType: ActionTypes.number, value: 7),
      SudokuAction(row: 3, col: 2, display: TextWidget(text: '8'), actionType: ActionTypes.number, value: 8),
      SudokuAction(row: 3, col: 3, display: TextWidget(text: '9'), actionType: ActionTypes.number, value: 9),
      SudokuAction(row: 1, col: 4, display: TextWidget(text: '9'), actionType: ActionTypes.bigType),
      SudokuAction(row: 2, col: 4, display: TextWidget(text: '789'), actionType: ActionTypes.extraType),
      SudokuAction(row: 3, col: 4, display: TextWidget(text: '789'), actionType: ActionTypes.mustType),
      SudokuAction(row: 0, col: 1, display: Icon(Icons.save), actionType: ActionTypes.saveControl),
      SudokuAction(row: 0, col: 2, display: Icon(Icons.undo), actionType: ActionTypes.undoControl),
      SudokuAction(row: 0, col: 3, display: Icon(Icons.redo), actionType: ActionTypes.redoControl),
      SudokuAction(row: 0, col: 4, display: Icon(Icons.restore_from_trash), actionType: ActionTypes.eraseControl),
      SudokuAction(row: 0, col: 5, display: Icon(Icons.edit), actionType: ActionTypes.fillControl),
      SudokuAction(row: 0, col: 6, display: Icon(Icons.lightbulb), actionType: ActionTypes.hintControl),
      SudokuAction(row: 0, col: 7, display: Icon(Icons.multiple_stop), actionType: ActionTypes.multipleControl),
    ];

    numberGroup = SudokuControllerGroup(actionsGrouped: actions.sublist(0, 9));
    noteTypeGroup = SudokuControllerGroup(actionsGrouped: actions.sublist(9, 12), actionSelectedValue: actions[9]);
    controllerGroup = SudokuControllerGroup(actionsGrouped:actions.sublist(12,actions.length -1));
    multipleControlGroup = SudokuControllerGroup(actionsGrouped: [actions.last]);
  }

  @override
  State<SudokuController> createState() => _SudokuControllerState();
}

class _SudokuControllerState extends State<SudokuController> {
  _action(SudokuAction element){
    SudokuLocation? loc = widget.actualBoard.value.selectedLocation;
    if(loc != null){
      print(loc);
      SudokuCell cell = widget.actualBoard.value.gameCells[(loc.row-1)*SudokuConstants().SUDOKU_SIZE_SQUARE+loc.col-1];
      switch(element.actionType){
        case ActionTypes.number:
          widget.numberGroup.actionSelected.value = element;
          switch(widget.noteTypeGroup.actionSelected.value?.actionType){
            case ActionTypes.bigType:
              SudokuMove move = SudokuMove(from: cell, to: SudokuCell.clone(cell)..value = element.value);
              print(move.from);
              print(move.to);
              widget.actualBoard.value = widget.actualBoard.value.getNewBoardFromMove(move);
              break;
            case ActionTypes.extraType:
              SudokuMove move = SudokuMove(from: cell, to: SudokuCell.clone(cell)..addOrRemoveExtra([element.value!]));
              widget.actualBoard.value = widget.actualBoard.value.getNewBoardFromMove(move);
              break;
            case ActionTypes.mustType:
              SudokuMove move = SudokuMove(from: cell, to: SudokuCell.clone(cell)..addOrRemoveMust([element.value!]));
              widget.actualBoard.value = widget.actualBoard.value.getNewBoardFromMove(move);
              break;
            default:
              assert(false);
          };
          break;
        case ActionTypes.bigType:
          widget.noteTypeGroup.actionSelected.value = element;
          break;
        case ActionTypes.extraType:
          widget.noteTypeGroup.actionSelected.value = element;
          break;
        case ActionTypes.mustType:
          widget.noteTypeGroup.actionSelected.value = element;
          break;
        case ActionTypes.saveControl:
          widget.controllerGroup.actionSelected.value = element;
          break;
        case ActionTypes.undoControl:
          widget.controllerGroup.actionSelected.value = element;
          break;
        case ActionTypes.redoControl:
          widget.controllerGroup.actionSelected.value = element;
          break;
        case ActionTypes.eraseControl:
          widget.controllerGroup.actionSelected.value = element;
          break;
        case ActionTypes.hintControl:
          widget.controllerGroup.actionSelected.value = element;
          break;
        case ActionTypes.fillControl:
          widget.controllerGroup.actionSelected.value = element;
          break;
        case ActionTypes.multipleControl:
          if(widget.multipleControlGroup.actionSelected.value == null){
            widget.multipleControlGroup.actionSelected.value = element;
          }else{
            widget.multipleControlGroup.actionSelected.value = null;
          }
          break;
      }
    }
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ...widget.actions.where((element) => element.row == 0).map((e){
              return InkWell(
                onTap: ()=> _action(e),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: e == widget.controllerGroup.actionSelected.value || e == widget.multipleControlGroup.actionSelected.value
                        ? getIt<AppColor>().greenMain : getIt<AppColor>().lightSecondary,
                  ),
                  child: Center(child: e.display)
                ),
              );
            }),
          ],
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(SudokuAction.SUDOKUACTIONROWS, (row){
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(SudokuAction.SUDOKUACTIONCOLS, (col) {
                    SudokuAction? e = widget.actions.firstWhereIfThere((element) => element.row == row + 1 && element.col == col + 1);
                    if(e == null){
                      return Container(
                        width: 50,
                        height: 50,
                      );
                    }
                    return InkWell(
                      onTap: ()=> _action(e),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: e == widget.numberGroup.actionSelected.value || e == widget.noteTypeGroup.actionSelected.value
                              ? getIt<AppColor>().greenMain : getIt<AppColor>().lightSecondary,
                        ),
                        child: Center(child: e.display)
                      ),
                    );
                  }),
                );
              }),
            ),
          ),
        )
      ],
    );
  }
}
