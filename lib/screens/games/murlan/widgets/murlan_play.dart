
import 'dart:math';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:game_template/screens/games/murlan/modals/murlan_state.dart';
import 'package:game_template/screens/games/murlan/widgets/indexer_widget.dart';
import 'package:game_template/services/app_styles/app_color.dart';
import 'package:game_template/services/get_it_helper.dart';
import 'package:game_template/widgets/button_widget.dart';
import 'package:game_template/widgets/text_widget.dart';
import '../../../cards/card_model.dart';
import '../../../cards/deck_model.dart';
enum Direction{
  left,
  right,
  top,
  bottom
}
class MurlanPlay extends StatelessWidget {
  ValueNotifier<MurlanState> murlanState;
  final double betweenCardsSpacing = 15;
  final double cardSelectedSpacing = 50;
  final double actionToCardSpacing = 5;
  MurlanPlay({
    Key? key,
    int playerCount = 4,
    required DeckModel deck,
  }) : murlanState = ValueNotifier(MurlanState(playerCount: playerCount, deck: deck)), super(key: key) {
    assert(murlanState.value.playerCount == 2 || murlanState.value.playerCount == 3 || murlanState.value.playerCount == 4);
  }

  @override
  Widget build(BuildContext context) {
    murlanState.value.currentError.addListener(() {
      if(murlanState.value.currentError.value != null) {
        showDialog(
            context: context,
            useSafeArea: true,
            builder: (context) {
              return AlertDialog(
                title: TextWidget(text: "Error"),
                content: TextWidget(text: murlanState.value.currentError.value!),
              );
            }
        );
      }
    });
    return ValueListenableBuilder(
      valueListenable: murlanState,
      builder: (context, _, __) {
        Map<int, Direction> playerPositions = {};
        switch(murlanState.value.playerCount){
          case 2: playerPositions = {
            1 : Direction.left,
            2 : Direction.right,
          }; break;
          case 3: playerPositions = {
            1 : Direction.left,
            2 : Direction.bottom,
            3 : Direction.top,
          }; break;
          case 4: playerPositions = {
            1 : Direction.left,
            2 : Direction.bottom,
            3 : Direction.right,
            4 : Direction.top,
          }; break;
        }
        return Stack(
          children: [
            ...playerPositions.entries.map((e) {
              bool thisPlayersTurn = murlanState.value.players[e.key-1].playerId == murlanState.value.playerTurn;

              double wholeCardStackWidth = (murlanState.value.players[e.key-1].initCount - 1) * betweenCardsSpacing + CardModel.CARD_SIZE.width;
              double? valNR = e.value != Direction.right ? 0 : null;
              double? valNL = e.value != Direction.left ? 0 : null;
              double? valNT = e.value != Direction.top ? 0 : null;
              double? valNB = e.value != Direction.bottom ? 0 : null;
              //print("${e.value} : ${murlanState.value.players[e.key - 1].cards.length}");
              int turns = 0;
              Axis lrH= e.value == Direction.left || e.value == Direction.right ? Axis.horizontal : Axis.vertical;
              //print("${e.value} $lrH");
              if(e.value == Direction.left){
                turns = 1;
              }else if(e.value == Direction.top){
                turns = 2;
              }else if(e.value == Direction.right){
                turns = 3;
              }
              //print(turns);
              return [
                Positioned(
                left: e.value == Direction.left ? -CardModel.CARD_SIZE.height/2 : valNR,
                bottom: e.value == Direction.bottom ? -CardModel.CARD_SIZE.height/2 :  valNT,
                right: e.value == Direction.right ? -CardModel.CARD_SIZE.height/2 : valNL,
                top: e.value == Direction.top ? -CardModel.CARD_SIZE.height/2 : valNB,
                child: RotatedBox(
                  quarterTurns: turns,
                  child: Center(
                    child: Indexer(
                      children: List.generate(murlanState.value.players[e.key-1].cards.length, (index) {
                        return Indexed(
                          child: GestureDetector(
                            onTapUp: (details) {
                              if(thisPlayersTurn){
                                murlanState.value.players[e.key-1].cards[index].toggleCardSelected();
                                murlanState.notifyListeners();
                              }
                            },
                            onTapDown: (details) {},
                            child: Container(
                              margin: EdgeInsets.only(
                                left: index * betweenCardsSpacing,
                                top: murlanState.value.players[e.key-1].cards[index].isCardSelected ? 0: cardSelectedSpacing,
                                bottom: murlanState.value.players[e.key-1].cards[index].isCardSelected ? cardSelectedSpacing: 0
                              ),height: CardModel.CARD_SIZE.height,
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all()
                              ),
                              width: CardModel.CARD_SIZE.width,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: murlanState.value.players[e.key-1].cards[index]
                                  ),
                                  Positioned.fill(child: IgnorePointer(child: Container(
                                    color: thisPlayersTurn ? null : Color(0x88ffffff)
                                  ))),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: e.value == Direction.left ? CardModel.CARD_SIZE.height/2 + cardSelectedSpacing + actionToCardSpacing : valNR,
                bottom: e.value == Direction.bottom ? CardModel.CARD_SIZE.height/2 + cardSelectedSpacing + actionToCardSpacing :  valNT,
                right: e.value == Direction.right ? CardModel.CARD_SIZE.height/2 + cardSelectedSpacing + actionToCardSpacing : valNL,
                top: e.value == Direction.top ? CardModel.CARD_SIZE.height/2 + cardSelectedSpacing + actionToCardSpacing : valNB,
                child: Center(
                  child: RotatedBox(
                      quarterTurns: turns,
                      child: Container(
                        width: wholeCardStackWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ButtonWidget(
                              textWidget: TextWidget(text: "Pass", textColor: thisPlayersTurn ? global.color.ink : Colors.grey),
                              action: thisPlayersTurn ? (){
                                bool res = murlanState.value.pass(murlanState.value.players[e.key-1]);
                                if(res){
                                  print("Changed");
                                  murlanState.notifyListeners();
                                }
                              }: null,
                            ),
                            ButtonWidget(
                              textWidget: TextWidget(text: "Throw", textColor: thisPlayersTurn ? global.color.ink : Colors.grey),
                              action: thisPlayersTurn ? (){
                                bool res = murlanState.value.throwCards(murlanState.value.players[e.key-1].cards.where((element) => element.isCardSelected).toList(), murlanState.value.players[e.key-1]);
                                if(res){
                                  print("Changed");
                                  murlanState.notifyListeners();
                                }
                              }: null,
                            ),
                          ],
                        ),
                      )
                  ),
                )
              ),
              Positioned(
                left: e.value == Direction.left ? 0 : valNR,
                bottom: e.value == Direction.bottom ? 0 : valNT,
                right: e.value == Direction.right ? 0 : valNL,
                top: e.value == Direction.top ? 0 : valNB,
                child: Center(
                  child: RotatedBox(
                      quarterTurns: turns,
                      child: Container(
                        color: Colors.yellow,
                        width: wholeCardStackWidth,
                        padding: EdgeInsets.all(5),
                        child: TextWidget(
                          text: murlanState.value.players[e.key-1].playerId,
                        )
                      )
                  ),
                )
              ),
              ];
            }).expand((element) => element).toList(),
            ...murlanState.value.tableState.asMap().entries.map((e) {
              //print("${e.key} -> ${e.value.cardsPlayed}");
              return Positioned(
                top: 20,
                bottom: 20,
                left: 20,
                right: 20,
                child: Center(
                  child: Transform.translate(
                    offset: e.value.dxdy,
                    child: Transform.rotate(
                      angle : e.value.angled,
                      child: RowSuper(
                        mainAxisSize: MainAxisSize.min,
                        innerDistance: betweenCardsSpacing - CardModel.CARD_SIZE.width,
                        children: e.value.cardsPlayed.map((el){
                          return Container(
                            width: CardModel.CARD_SIZE.width,
                            height: CardModel.CARD_SIZE.height,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  color: e.key == murlanState.value.tableState.length - 1 ? Colors.red : Colors.black
                              )
                            ),
                            child: el
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              );
            })
          ],
        );
      },
    );
  }
}
