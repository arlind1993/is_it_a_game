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
  @override
  void initState() {
    actualSudokuBoard = ValueNotifier(widget.sudokuState);

    actualSudokuBoard.addListener(() {
      _logger.info("\n"+actualSudokuBoard.value.toGridVisual());
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
    return Container(
      child: LayoutBuilder(
        builder: (context, constraint) {
          print(constraint.maxHeight);
          double screenSize = constraint.maxWidth;
          return SizedBox(
            width: screenSize,
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
                                            text: cell.value.toString()
                                          )
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
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
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
                Positioned(
                  top: screenSize,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    child: SudokuController(
                      actualBoard: actualSudokuBoard
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
