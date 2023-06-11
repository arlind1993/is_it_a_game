import 'package:flutter/material.dart';
import 'package:game_template/screens/games/chess/models/chess_possible_move_group.dart';

import '../models/chess_constants.dart';

class ChessPromotionPopUp extends StatelessWidget {
  PossibleMoveGroup possibleMoveGroup;
  ValueNotifier<PossibleMoveGroup?> pawnPromotion;
  ChessPromotionPopUp(
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: (possibleMoveGroup.pieceMovement.from.isWhite
                      ? ["Q","R","N","B"] : ["q","r","n","b"]).map((e) {
                      return GestureDetector(
                        onTap: () {
                          PossibleMoveGroup newMove = PossibleMoveGroup.clone(possibleMoveGroup);
                          switch(e.toLowerCase()){
                            case 'b':
                              newMove.pieceMovement.to.pieceType = ChessPieceType.Bishop;
                              break;
                            case 'n':
                              newMove.pieceMovement.to.pieceType = ChessPieceType.Knight;
                              break;
                            case 'r':
                              newMove.pieceMovement.to.pieceType = ChessPieceType.Rook;
                              break;
                            case 'q':
                            default :
                              newMove.pieceMovement.to.pieceType = ChessPieceType.Queen;
                              break;
                          }
                          pawnPromotion.value = newMove;
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: constraint.maxWidth / ChessConstants().CHESS_SIZE_SQUARE,
                          height: constraint.maxWidth / ChessConstants().CHESS_SIZE_SQUARE,
                          child: ChessConstants().chessPiecePictures[e],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              )
            ),
          ),
        );
      },
    );
  }
}
