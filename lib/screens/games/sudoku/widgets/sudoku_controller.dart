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
  bool initialised = false;
  late List<SudokuAction> actionsGrouped;
  late ValueNotifier<SudokuAction?> actionSelected;
  SudokuControllerGroup.setActions({
    required this.actionsGrouped,
    SudokuAction? actionSelectedValue,
  }): actionSelected = ValueNotifier(actionSelectedValue), initialised = true;

  SudokuControllerGroup();

  void setActions({
    required actionsGrouped,
    SudokuAction? actionSelectedValue,
  }){
    this.actionsGrouped = actionsGrouped;
    actionSelected = ValueNotifier(actionSelectedValue);
    initialised = true;
  }

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
    required this.numberGroup,
    required this.noteTypeGroup,
    required this.controllerGroup,
    required this.multipleControlGroup,
  }) {
    actions = [
      SudokuAction(row: 1, col: 1, display: TextWidget(text: '1', textSize: 22), actionType: ActionTypes.number, value: 1),
      SudokuAction(row: 1, col: 2, display: TextWidget(text: '2', textSize: 22), actionType: ActionTypes.number, value: 2),
      SudokuAction(row: 1, col: 3, display: TextWidget(text: '3', textSize: 22), actionType: ActionTypes.number, value: 3),
      SudokuAction(row: 2, col: 1, display: TextWidget(text: '4', textSize: 22), actionType: ActionTypes.number, value: 4),
      SudokuAction(row: 2, col: 2, display: TextWidget(text: '5', textSize: 22), actionType: ActionTypes.number, value: 5),
      SudokuAction(row: 2, col: 3, display: TextWidget(text: '6', textSize: 22), actionType: ActionTypes.number, value: 6),
      SudokuAction(row: 3, col: 1, display: TextWidget(text: '7', textSize: 22), actionType: ActionTypes.number, value: 7),
      SudokuAction(row: 3, col: 2, display: TextWidget(text: '8', textSize: 22), actionType: ActionTypes.number, value: 8),
      SudokuAction(row: 3, col: 3, display: TextWidget(text: '9', textSize: 22), actionType: ActionTypes.number, value: 9),
      SudokuAction(row: 1, col: 4, display: Container(
        alignment: Alignment.center,
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border.all(width: 2),
          borderRadius: BorderRadius.circular(5),
        ),
        child: TextWidget(text: '9')
      ), actionType: ActionTypes.bigType),
      SudokuAction(row: 2, col: 4, display: Container(
        alignment: Alignment.center,
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border.all(width: 2),
          borderRadius: BorderRadius.circular(5),
        ),
        child: TextWidget(text: '789', textSize: 10,)
      ), actionType: ActionTypes.mustType),
      SudokuAction(row: 3, col: 4, display: Container(
          alignment: Alignment.center,
          width: 30,
          height: 30,
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            border: Border.all(width: 2),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextWidget(text: '7', textSize: 10, lineHeight: 1,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget(text: '8', textSize: 10, lineHeight: 1,),
                  TextWidget(text: '9', textSize: 10, lineHeight: 1,),
                ],
              ),
            ],
          )
      ), actionType: ActionTypes.extraType),
      SudokuAction(row: 0, col: 1, display: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.save), TextWidget(text: "Save", )]), actionType: ActionTypes.saveControl),
      SudokuAction(row: 0, col: 2, display: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.undo), TextWidget(text: "Undo", )]), actionType: ActionTypes.undoControl),
      SudokuAction(row: 0, col: 3, display: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.redo), TextWidget(text: "Redo", )]), actionType: ActionTypes.redoControl),
      SudokuAction(row: 0, col: 4, display: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.restore_from_trash), TextWidget(text: "Empty", )]), actionType: ActionTypes.eraseControl),
      SudokuAction(row: 0, col: 5, display: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.edit), TextWidget(text: "Fill", )]), actionType: ActionTypes.fillControl),
      SudokuAction(row: 0, col: 6, display: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.lightbulb), TextWidget(text: "Hint", )]), actionType: ActionTypes.hintControl),
      SudokuAction(row: 0, col: 7, display: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.multiple_stop), TextWidget(text: "Multi", )]), actionType: ActionTypes.multipleControl),
    ];

    numberGroup.setActions(actionsGrouped: actions.sublist(0, 9));
    noteTypeGroup.setActions(actionsGrouped: actions.sublist(9, 12), actionSelectedValue: actions[9]);
    controllerGroup.setActions(actionsGrouped:actions.sublist(12,actions.length -1));
    multipleControlGroup.setActions(actionsGrouped: [actions.last]);
  }

  @override
  State<SudokuController> createState() => _SudokuControllerState();
}

class _SudokuControllerState extends State<SudokuController> {
  _action(SudokuAction element){
    SudokuLocation? loc = widget.actualBoard.value.selectedLocation;
      print(loc);
      SudokuCell? cell;
      if(loc != null){
        cell= widget.actualBoard.value.gameCells[(loc.row-1)*SudokuConstants().SUDOKU_SIZE_SQUARE+loc.col-1];
      }
      switch(element.actionType){
        case ActionTypes.number:
          if(cell != null && cell.type == SudokuCellType.mutable){
            widget.numberGroup.actionSelected.value = element;
            switch(widget.noteTypeGroup.actionSelected.value?.actionType){
              case ActionTypes.bigType:
                SudokuMove move = SudokuMove(from: cell, to: SudokuCell.clone(cell)..addOrRemoveValue(element.value!));
                bool change = widget.actualBoard.value.makeMove(move);
                if(change) widget.actualBoard.notifyListeners();
                break;
              case ActionTypes.mustType:
                if(cell.value != null) break;
                SudokuMove move = SudokuMove(from: cell, to: SudokuCell.clone(cell)..addOrRemoveMust([element.value!]));
                bool change = widget.actualBoard.value.makeMove(move);
                if(change) widget.actualBoard.notifyListeners();
                break;
              case ActionTypes.extraType:
                if(cell.value != null || cell.must != 0) break;
                SudokuMove move = SudokuMove(from: cell, to: SudokuCell.clone(cell)..addOrRemoveExtra([element.value!]));
                bool change = widget.actualBoard.value.makeMove(move);
                if(change) widget.actualBoard.notifyListeners();
                break;
              default:
                assert(false);
            };
          }
          break;
        case ActionTypes.bigType:
          widget.noteTypeGroup.actionSelected.value = element;
          break;
        case ActionTypes.mustType:
          widget.noteTypeGroup.actionSelected.value = element;
          break;
        case ActionTypes.extraType:
          widget.noteTypeGroup.actionSelected.value = element;
          break;
        case ActionTypes.saveControl:
          //TODO: ADD SAVE
          widget.controllerGroup.actionSelected.value = element;
          break;
        case ActionTypes.undoControl:
          widget.controllerGroup.actionSelected.value = element;
          bool change = widget.actualBoard.value.undo();
          if(change) widget.actualBoard.notifyListeners();
          break;
        case ActionTypes.redoControl:
          widget.controllerGroup.actionSelected.value = element;
          bool change = widget.actualBoard.value.redo();
          if(change) widget.actualBoard.notifyListeners();
          break;
        case ActionTypes.eraseControl:
          widget.controllerGroup.actionSelected.value = element;
          if(cell != null && cell.type == SudokuCellType.mutable){
            SudokuMove move = SudokuMove(from: cell, to: SudokuCell.clone(cell)..value=null..must=0..extra=0);
            bool change = widget.actualBoard.value.makeMove(move);
            if(change) widget.actualBoard.notifyListeners();
          }
          break;
        case ActionTypes.hintControl:
          //TODO: ADD HINT
          widget.controllerGroup.actionSelected.value = element;
          break;
        case ActionTypes.fillControl:
          widget.controllerGroup.actionSelected.value = element;
          if(cell != null && cell.type == SudokuCellType.mutable){
            if(cell.value != null) break;
            late SudokuMove move;
            if(cell.must != 0 || widget.noteTypeGroup.actionSelected.value?.actionType == ActionTypes.mustType){
              move = SudokuMove(from: cell, to: SudokuCell.clone(cell)..must=0..addOrRemoveExtra(
                  List<int>.generate(SudokuConstants().SUDOKU_SIZE_SQUARE, (index) => index+1)
              ));
            }else{
              move = SudokuMove(from: cell, to: SudokuCell.clone(cell)..extra=0..addOrRemoveExtra(
                  List<int>.generate(SudokuConstants().SUDOKU_SIZE_SQUARE, (index) => index+1)
              ));
            }
            bool change = widget.actualBoard.value.makeMove(move);
            if(change) widget.actualBoard.notifyListeners();
          }
          break;
        case ActionTypes.multipleControl:
          if(widget.multipleControlGroup.actionSelected.value == null){
            widget.multipleControlGroup.actionSelected.value = element;
          }else{
            widget.multipleControlGroup.actionSelected.value = null;
          }//TODO ADD  MULTIPLE SELECT ON CLICK CELL NOT HERE
          break;
      }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      child: Column(
        children: [
          SizedBox(height: 5,),
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
                        borderRadius: BorderRadius.circular(10)
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
                          margin: EdgeInsets.all(2.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
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
      ),
    );
  }
}
