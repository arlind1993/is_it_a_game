import 'dart:math';

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
import 'sudoku_controller.dart';


class SudokuPlayBoard extends StatefulWidget {
  SudokuBoardState sudokuState;
  bool youAreWhite;
  bool initialised;
  String? roomId;
  bool online;
  SudokuPlayBoard({
    super.key,
    String importedFenString = "508000093000000506769538001000005000000067000010324900000090600172050309956400002",
    this.roomId,
    this.youAreWhite = true,
    this.online = false
  }) :
    initialised = roomId != null,
    sudokuState = SudokuImportAlgorithms().importBoard(importedFenString);

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
  };
  @override
  void initState() {
    actualSudokuBoard = ValueNotifier(widget.sudokuState);

    actualSudokuBoard.addListener(() {
      _logger.info(actualSudokuBoard.value.toGridVisual());
      widget.sudokuState = actualSudokuBoard.value;
    });

    super.initState();
  }

  @override
  void dispose() {
    actualSudokuBoard.dispose();
    super.dispose();
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
                            onTap: () {
                              SudokuCell actualCell = actualSudokuBoard.value.gameCells[row*SudokuConstants().SUDOKU_SIZE_SQUARE+col];
                              if(actualCell.type != SudokuCellType.filled){
                                actualSudokuBoard.value.selectedLocation = actualCell.sudokuLocation;
                                actualSudokuBoard.notifyListeners();
                              }
                            },
                            onLongPress: () {
                              SudokuCell actualCell = actualSudokuBoard.value.gameCells[row*SudokuConstants().SUDOKU_SIZE_SQUARE+col];
                              if(actualCell.type != SudokuCellType.filled){
                                if(actualSudokuBoard.value.selectedLocation == actualCell.sudokuLocation){
                                  actualSudokuBoard.value.selectedLocation = null;
                                }else{
                                  actualSudokuBoard.value.selectedLocation = actualCell.sudokuLocation;
                                }
                                actualSudokuBoard.notifyListeners();
                              }
                            },
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
                                      if(cell.value != null){
                                        return Center(
                                          child: TextWidget(
                                            text: cell.value.toString(),
                                            textSize: 22,
                                          )
                                        );
                                      }
                                      print(cell.listMust);
                                      print(cell.listExtra);
                                      if(cell.must!=0){
                                        return Center(
                                          child: TextWidget(
                                            text: cell.listMust.join(""),
                                            lineHeight: 1,
                                            textSize: 12,
                                          )
                                        );
                                      }
                                      if(cell.extra!=0){
                                        int sq = sqrt(SudokuConstants().SUDOKU_SIZE_SQUARE).ceil();
                                        return Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: List.generate(sq, (row) => Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: List.generate(sq, (col) {
                                              if(cell.listExtra.contains(row*sq+col+1)){
                                                return TextWidget(
                                                  text:"${row*sq+col+1}",
                                                  lineHeight: 1,
                                                  textSize: 10,
                                                );
                                              }
                                              return TextWidget(
                                                text:" ",
                                                lineHeight: 1,
                                                textSize: 10,
                                              );
                                            }),
                                          ))
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
