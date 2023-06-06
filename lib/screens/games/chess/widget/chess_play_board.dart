import 'package:flutter/material.dart';
import 'package:game_template/screens/games/chess/logic/chess_logic.dart';
import 'package:game_template/screens/games/chess/widget/chess_board_builder.dart';
import 'package:game_template/services/app_styles/app_color.dart';
import 'package:game_template/services/get_it_helper.dart';

import '../chess_constants.dart';


class ChessPlayBoard extends StatefulWidget {
  ChessPlayBoard({
    super.key,
  });

  @override
  State<ChessPlayBoard> createState() => _ChessPlayBoardState();
}

class _ChessPlayBoardState extends State<ChessPlayBoard> {
  late bool youAreWhite;
  late String fenString;
  
  @override
  void initState() {
    super.initState();
    youAreWhite = true;
    fenString = "";
  }
  
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
                children: List.generate(ChessConstants().CHESS_SIZE_SQUARE, (rankIndex){
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(ChessConstants().CHESS_SIZE_SQUARE, (fileIndex){
                      return Container(
                        width: screenSize/ChessConstants().CHESS_SIZE_SQUARE,
                        height: screenSize/ChessConstants().CHESS_SIZE_SQUARE,
                        color: (rankIndex + fileIndex) % 2 == 0
                          ? getIt<AppColor>().beigeMain
                          : getIt<AppColor>().brownMain,
                      );
                    })
                  );
                }),
              ),
              Positioned.fill(
                child: ChessBoardBuilder(youAreWhite: youAreWhite, importFen: fenString),
              ),
            ],
          )
        );
      }
    );
  }
}
