import 'package:flutter/material.dart';
import 'package:game_template/services/app_styles/app_color.dart';
import 'package:game_template/services/get_it_helper.dart';

class ChessPlayBoard extends StatelessWidget {
  static const int square = 8;
  const ChessPlayBoard({super.key});

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
                children: List.generate(square, (rankIndex){
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(square, (fileIndex){
                      return Container(
                        width: screenSize/square,
                        height: screenSize/square,
                        color: (rankIndex + fileIndex) % 2 == 0
                          ? getIt<AppColor>().beigeMain
                          : getIt<AppColor>().brownMain,
                      );
                    })
                  );
                }),
              ),
              Row(
                children: [
                  Draggable<String>(
                    data: "king",
                    feedback:Container(
                       width: screenSize/square,
                       height: screenSize/square,
                       color: getIt<AppColor>().darkMain,
                    ),
                    child: Container(
                      width: screenSize/square,
                      height: screenSize/square,
                      color: getIt<AppColor>().lightMain,
                    ),
                    childWhenDragging: Container(
                      width: screenSize/square,
                      height: screenSize/square,
                      color: getIt<AppColor>().brownSecondary,
                    ),
                  ),
                ],
              ),
              DragTarget(
                onAccept: (data) {

                },
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    margin: EdgeInsets.only(left: screenSize/square),
                    width: screenSize/square,
                    height: screenSize/square,
                    color: Colors.red,
                  );
                },
              ),
              DragTarget(
                onAccept: (data) {

                },
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    margin: EdgeInsets.only(left: screenSize/square * 2),
                    width: screenSize/square,
                    height: screenSize/square,
                    color: Colors.red,
                  );
                },
              )
            ],
          )
        );
      }
    );
  }
}
