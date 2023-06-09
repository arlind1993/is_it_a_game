import 'package:flutter/material.dart';
import 'package:game_template/screens/games/chess/models/chess_possible_move_group.dart';

class ChessPromotionPopUp extends StatelessWidget {
  PossibleMoveGroup possibleMoveGroup;
  ValueNotifier<PossibleMoveGroup> pawnPromotion;
  const ChessPromotionPopUp(
  this.possibleMoveGroup,
  this.pawnPromotion {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: (tempPawn.isWhite ? [
                    "Q","R","N","B"
                  ]:[
                    "q","r","n","b"
                  ]).map((e) => Container(
                    width: constraint.maxWidth / ChessConstants().CHESS_SIZE_SQUARE,
                    height: constraint.maxWidth / ChessConstants().CHESS_SIZE_SQUARE,
                    child: ChessConstants().chessPiecePictures[e],
                  )).toList(),
                ),
              ),
            )
        ),
      ),
    );
  }
}
