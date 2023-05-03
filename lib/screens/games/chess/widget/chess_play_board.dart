import 'package:flutter/material.dart';
import 'package:game_template/screens/games/chess/chess_logic.dart';
import 'package:game_template/screens/games/chess/widget/chess_board_builder.dart';
import 'package:game_template/services/app_styles/app_color.dart';
import 'package:game_template/services/get_it_helper.dart';


class ChessPlayBoard extends StatefulWidget {
  late ChessBoardState importBoard;
  ChessPlayBoard({
    super.key,
    ChessBoardState? import,
  }){
    importBoard = import ?? ChessBoardState();
  }

  @override
  State<ChessPlayBoard> createState() => _ChessPlayBoardState();
}

class _ChessPlayBoardState extends State<ChessPlayBoard> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        double screenSize = constraint.maxWidth;
        return SizedBox(
          width: screenSize,
          height: screenSize,
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(ChessBoardState.SQUARE, (rankIndex){
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(ChessBoardState.SQUARE, (fileIndex){
                      return Container(
                        width: screenSize/ChessBoardState.SQUARE,
                        height: screenSize/ChessBoardState.SQUARE,
                        color: (rankIndex + fileIndex) % 2 == 0
                          ? getIt<AppColor>().beigeMain
                          : getIt<AppColor>().brownMain,
                      );
                    })
                  );
                }),
              ),
              Positioned.fill(
                child: ChessBoardBuilder(chessBoardState: widget.importBoard)
              ),
            ],
          )
        );
      }
    );
  }
}
