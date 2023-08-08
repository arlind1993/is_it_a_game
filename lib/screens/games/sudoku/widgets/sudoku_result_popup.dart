import 'package:flutter/material.dart';
import 'package:game_template/screens/games/chess/models/chess_possible_move_group.dart';

class SudokuPromotionPopUp extends StatelessWidget {
  PossibleMoveGroup possibleMoveGroup;
  ValueNotifier<PossibleMoveGroup?> pawnPromotion;
  SudokuPromotionPopUp(
    this.possibleMoveGroup,
    this.pawnPromotion, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return Container(
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              color: Colors.black38,
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white54,
                  ),
                  child: Container(),
                ),
              )
            ),
          ),
        );
      },
    );
  }
}
