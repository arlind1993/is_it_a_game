import 'dart:math';

import 'package:game_template/screens/games/sudoku/models/sudoku_action.dart';
import 'package:game_template/screens/games/sudoku/models/sudoku_location.dart';
import 'package:game_template/widgets/text_widget.dart';
import 'package:logging/logging.dart';
import 'package:flutter/material.dart';
import 'package:game_template/services/app_styles/app_color.dart';
import 'package:game_template/services/get_it_helper.dart';
import '../logic/sudoku_logic.dart';
import '../models/sudoku_board_state.dart';
import '../models/sudoku_constants.dart';
import '../models/sudoku_cell.dart';
import '../models/sudoku_move.dart';
import 'sudoku_controller.dart';


class SudokuPlayBoard extends StatefulWidget {
  SudokuBoardState initialSudoku;
  bool youAreWhite;
  bool initialised;
  String? roomId;
  bool online;
  //100200300004000050006070000060030084000000000970010060000060700030000900005008002
  //157284396324691857896573421261739584543826179978415263489362715632157948715948632
  SudokuPlayBoard({
    super.key,
    String importedFenString = "157284396324691857896573421261739584543826179978415263489362715632157948715948000",
    this.roomId,
    this.youAreWhite = true,
    this.online = false
  }) :
    initialised = roomId != null,
    initialSudoku = SudokuImportAlgorithms().importBoard(importedFenString);

  @override
  State<SudokuPlayBoard> createState() => _SudokuPlayBoardState();
}

class _SudokuPlayBoardState extends State<SudokuPlayBoard> {

  Logger _logger = Logger("Sudoku board builder");
  late ValueNotifier<SudokuBoardState> actualSudokuBoard;
  Map<String, SudokuControllerGroup> sudokuActionGroups = {
    "numberGroup": SudokuControllerGroup(),
    "noteTypeGroup": SudokuControllerGroup(),
    "controllerGroup": SudokuControllerGroup(),
    "multipleControlGroup": SudokuControllerGroup(),
    "bigEditGroup": SudokuControllerGroup(),
  };
  @override
  void initState() {
    actualSudokuBoard = ValueNotifier(widget.initialSudoku);

    actualSudokuBoard.addListener(() {
      _logger.info(actualSudokuBoard.value.toGridVisual());
      if(actualSudokuBoard.value.gameCells.every((element) => element.value != null)
        && actualSudokuBoard.value.onlyErrorsInCells.every((element) => element.value == null)){

      }
    });

    super.initState();
  }

  @override
  void dispose() {
    actualSudokuBoard.dispose();
    super.dispose();
  }


  void _action(int row, int col, {bool held = false, bool double = false}) {

    SudokuCell actualCell = actualSudokuBoard.value.gameCells[row*SudokuConstants().SUDOKU_SIZE_SQUARE+col];
    if(actualCell.type != SudokuCellType.filled){
      print(held);
      if(actualSudokuBoard.value.selectedLocation == actualCell.sudokuLocation && held){
        actualSudokuBoard.value.selectedLocation = null;
      }else{
        actualSudokuBoard.value.selectedLocation = actualCell.sudokuLocation;
      }
      print("hi -> ${actualSudokuBoard.value.selectedLocation}");
      if(actualCell.type == SudokuCellType.mutable && actualSudokuBoard.value.selectedLocation != null && sudokuActionGroups["multipleControlGroup"]!.actionSelected.value != null){
        if(sudokuActionGroups["bigEditGroup"]!.actionSelected.value?.actionType == ActionTypes.eraseControl){
          SudokuMove move = SudokuMove(from: actualCell, to: SudokuCell.clone(actualCell)..value=null..must=0..extra=0);
          if(double && actualCell.value==null && actualCell.must==0) {
            SudokuCell errorCell = actualSudokuBoard.value.onlyErrorsInCells[row*SudokuConstants().SUDOKU_SIZE_SQUARE+col];
            move = SudokuMove(from: actualCell, to: SudokuCell.clone(actualCell)..addOrRemoveExtra(errorCell.listExtra));
          }
          bool change = actualSudokuBoard.value.makeMove(move);
          if(change) actualSudokuBoard.notifyListeners();
        }else if(sudokuActionGroups["bigEditGroup"]!.actionSelected.value?.actionType == ActionTypes.fillControl){
          if(actualCell.value == null) {
            late SudokuMove move;
            if(actualCell.must != 0 || sudokuActionGroups["noteTypeGroup"]!.actionSelected.value?.actionType == ActionTypes.mustType){
              move = SudokuMove(from: actualCell, to: SudokuCell.clone(actualCell)..must=0..addOrRemoveExtra(
                List<int>.generate(SudokuConstants().SUDOKU_SIZE_SQUARE, (index) => index+1)
              ));
            }else{
              move = SudokuMove(from: actualCell, to: SudokuCell.clone(actualCell)..extra=0..addOrRemoveExtra(
                List<int>.generate(SudokuConstants().SUDOKU_SIZE_SQUARE, (index) => index+1)
              ));
            }
            bool change = actualSudokuBoard.value.makeMove(move);
            if(change) actualSudokuBoard.notifyListeners();
          }
        }else{
          int? value = sudokuActionGroups["numberGroup"]!.actionSelected.value?.value;
          if(value != null){
            switch(sudokuActionGroups["noteTypeGroup"]!.actionSelected.value?.actionType){
              case ActionTypes.bigType:
                SudokuMove move = SudokuMove(from: actualCell, to: SudokuCell.clone(actualCell)..addOrRemoveValue(value));
                bool change = actualSudokuBoard.value.makeMove(move);
                if(change) actualSudokuBoard.notifyListeners();
                break;
              case ActionTypes.mustType:
                if(actualCell.value != null) break;
                SudokuMove move = SudokuMove(from: actualCell, to: SudokuCell.clone(actualCell)..addOrRemoveMust([value]));
                bool change = actualSudokuBoard.value.makeMove(move);
                if(change) actualSudokuBoard.notifyListeners();
                break;
              case ActionTypes.extraType:
                if(actualCell.value != null || actualCell.must != 0) break;
                SudokuMove move = SudokuMove(from: actualCell, to: SudokuCell.clone(actualCell)..addOrRemoveExtra([value]));
                bool change = actualSudokuBoard.value.makeMove(move);
                if(change) actualSudokuBoard.notifyListeners();
                break;
              default:
                assert(false);
            }
          }
        }
        print("hi");

      }
      actualSudokuBoard.notifyListeners();
    }
  }

  @override
  Widget build(BuildContext context) {
    double sch = MediaQuery.of(context).size.height;
    return Container(
      child: LayoutBuilder(
        builder: (context, constraint) {
          print(constraint.maxHeight);
          double screenSize = min(constraint.maxWidth, sch / 2);
          return SizedBox(
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(SudokuConstants().SUDOKU_SIZE_SQUARE, (row){
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(SudokuConstants().SUDOKU_SIZE_SQUARE, (col){
                          return GestureDetector(
                            onTap: () => _action(row, col),
                            onLongPress: () => _action(row, col, held: true),
                            onDoubleTap: () => _action(row, col, double: true),
                            child: ValueListenableBuilder(
                              valueListenable: actualSudokuBoard,
                              builder: (context, _, __) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: actualSudokuBoard.value.selectedLocation==SudokuLocation(row: row+1,col: col+1)
                                        ? getIt<AppColor>().greenMain
                                        : getIt<AppColor>().lightSecondary,
                                    border: Border.all(
                                      color: getIt<AppColor>().darkSecondary,
                                    )
                                  ),
                                  width: screenSize/SudokuConstants().SUDOKU_SIZE_SQUARE,
                                  height: screenSize/SudokuConstants().SUDOKU_SIZE_SQUARE,
                                  child: Builder(
                                    builder: (context) {
                                      SudokuCell cell = actualSudokuBoard.value.gameCells[row*SudokuConstants().SUDOKU_SIZE_SQUARE+col];
                                      SudokuCell errorsInCell = actualSudokuBoard.value.onlyErrorsInCells[row*SudokuConstants().SUDOKU_SIZE_SQUARE+col];
                                      if(cell.value != null){
                                        return Center(
                                          child: Container(
                                            color: cell.value == actualSudokuBoard.value.highlightedValue ? getIt<AppColor>().greenContrast : null,
                                            child: TextWidget(
                                              lineHeight: 1,
                                              text: cell.value.toString(),
                                              textSize: 22,
                                              textColor: cell.type == SudokuCellType.initial ? Colors.blue : errorsInCell.value !=null ? Colors.red : null,
                                            )
                                          ),
                                        );
                                      }
                                      print(cell.listMust);
                                      print(cell.listExtra);
                                      if(cell.must!=0){
                                        return Center(
                                          child: Wrap(
                                            alignment: WrapAlignment.center,
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            children: cell.listMust.map((e) {
                                              return Container(
                                                color: e == actualSudokuBoard.value.highlightedValue ? getIt<AppColor>().greenContrast : null,
                                                child: TextWidget(
                                                  text: e.toString(),
                                                  lineHeight: 1,
                                                  textSize: 12,
                                                  textColor: errorsInCell.listMust.contains(e) ? Colors.red : null,
                                                ),
                                              );
                                            }).toList()
                                          )
                                        );
                                      }
                                      if(cell.extra!=0){
                                        int sq = SudokuConstants().SUDOKU_SIZE_SQUARE_GROUP;
                                        return Container(
                                          padding: EdgeInsets.all(2),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: List.generate(sq, (row) => Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: List.generate(sq, (col) {
                                                int e = row*sq+col+1;
                                                if(cell.listExtra.contains(e)){
                                                  return Container(
                                                    color: e == actualSudokuBoard.value.highlightedValue ? getIt<AppColor>().greenContrast : null,
                                                    child: TextWidget(
                                                      text:"${row*sq+col+1}",
                                                      lineHeight: 1,
                                                      textSize: 10,
                                                      textColor: errorsInCell.listExtra.contains(e) ? Colors.red : null,
                                                    ),
                                                  );
                                                }
                                                return TextWidget(
                                                  text:" ",
                                                  lineHeight: 1,
                                                  textSize: 10,
                                                );
                                              }),
                                            ))
                                          ),
                                        );
                                      }
                                      return Container();
                                    },
                                  ),
                                );
                              }
                            ),
                          );
                        })
                      );
                    }),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: screenSize,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(2, (index) => Container(
                          width: 4,
                          height: screenSize,
                          color: getIt<AppColor>().darkSecondary,
                        )),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      height: screenSize,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(2, (index) => Container(
                          width: screenSize,
                          height: 4,
                          color: getIt<AppColor>().darkSecondary,
                        )),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: screenSize,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    child: SudokuController(
                      actualBoard: actualSudokuBoard,
                      numberGroup: sudokuActionGroups["numberGroup"]!,
                      noteTypeGroup: sudokuActionGroups["noteTypeGroup"]!,
                      controllerGroup: sudokuActionGroups["controllerGroup"]!,
                      multipleControlGroup: sudokuActionGroups["multipleControlGroup"]!,
                      bigEditGroup: sudokuActionGroups["bigEditGroup"]!,
                    ),
                  ),
                )
              ],
            )
          );
        }
      ),
    );
  }

}
