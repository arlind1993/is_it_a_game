
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:game_template/screens/games/murlan/modals/murlan_state.dart';
import 'package:game_template/screens/games/murlan/widgets/indexer_widget.dart';
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

              double wholeCardStackWidth = (murlanState.value.players[e.key-1].cards.length - 1) * betweenCardsSpacing + CardModel.CARD_WIDTH;
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
                left: e.value == Direction.left ? -CardModel.CARD_HEIGHT/2 : valNR,
                bottom: e.value == Direction.bottom ? -CardModel.CARD_HEIGHT/2 :  valNT,
                right: e.value == Direction.right ? -CardModel.CARD_HEIGHT/2 : valNL,
                top: e.value == Direction.top ? -CardModel.CARD_HEIGHT/2 : valNB,
                child: Center(
                  child: Indexer(
                    children: List.generate(murlanState.value.players[e.key-1].cards.length, (index) {
                      // print("EdgeInsets.only(\n"
                      //     "left: ${e.value} == left && ${murlanState.value.players[e.key-1].cards[index].selected} ? 20 : ${e.value} == Direction.bottom ? ${index * 10} : 0, => ${e.value == Direction.left && murlanState.value.players[e.key-1].cards[index].selected ? 20 : e.value == Direction.bottom || e.value == Direction.top? index * 20 : 0}\n"
                      //     "bottom: ${e.value} == bottom && ${murlanState.value.players[e.key-1].cards[index].selected} ? 20 : 0, => ${e.value == Direction.bottom && murlanState.value.players[e.key-1].cards[index].selected ? 20 : 0}\n"
                      //     "right: ${e.value} == right && ${murlanState.value.players[e.key-1].cards[index].selected} ? 20 : 0, => ${e.value == Direction.right && murlanState.value.players[e.key-1].cards[index].selected ? 20 : 0}\n"
                      //     "top: ${e.value} == top && ${murlanState.value.players[e.key-1].cards[index].selected} ? 20 : ${e.value} == Direction.left ? ${index * 10} : 0, => ${e.value == Direction.top && murlanState.value.players[e.key-1].cards[index].selected ? 20 : e.value == Direction.left || e.value == Direction.right ? index * 20 : 0}\n"
                      //     "),");

                      double width = (e.value == Direction.top || e.value == Direction.bottom) ? CardModel.CARD_WIDTH : CardModel.CARD_HEIGHT;
                      double height = (e.value == Direction.top || e.value == Direction.bottom) ? CardModel.CARD_HEIGHT : CardModel.CARD_WIDTH;
                      double left = 0;
                      double top = 0;

                      if(e.value == Direction.left && murlanState.value.players[e.key-1].cards[index].selected
                          || e.value == Direction.right && !murlanState.value.players[e.key-1].cards[index].selected){
                        left = cardSelectedSpacing;
                      }else if(e.value == Direction.bottom || e.value == Direction.top){
                        left = index * betweenCardsSpacing;
                      }
                      if(e.value == Direction.top && murlanState.value.players[e.key-1].cards[index].selected
                          || e.value == Direction.bottom && !murlanState.value.players[e.key-1].cards[index].selected){
                        top = cardSelectedSpacing;
                      }else if(e.value == Direction.left || e.value == Direction.right){
                        top = index * betweenCardsSpacing;
                      }
                      return Indexed(
                        child: GestureDetector(
                          onTapUp: (details) {
                            //print(details);
                            murlanState.value.players[e.key-1].cards[index].toggle();
                            murlanState.notifyListeners();
                          },
                          onTapDown: (details) {
                            //print(details);
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                              left: left,
                              top: top,
                            ),
                            width: width,
                            height: height,
                            decoration: BoxDecoration(
                              // color: e.value == Direction.left ? Colors.purple : e.value == Direction.bottom ? Colors.blue : e.value == Direction.right ? Colors.orange : Colors.red,
                              //border: Border.all(),
                            ),
                            child: RotatedBox(
                              quarterTurns: turns,
                              child: Stack(
                                children: [
                                  Positioned.fill(child: murlanState.value.players[e.key-1].cards[index].card),
                                  Positioned.fill(child: IgnorePointer(child: Container(
                                    color: murlanState.value.players[e.key-1].playerId == murlanState.value.playerTurn ? null : Color(0x88ffffff)
                                  ))),
                                ],
                              )
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              Positioned(
                left: e.value == Direction.left ? CardModel.CARD_HEIGHT/2 + cardSelectedSpacing + actionToCardSpacing : valNR,
                bottom: e.value == Direction.bottom ? CardModel.CARD_HEIGHT/2 + cardSelectedSpacing + actionToCardSpacing :  valNT,
                right: e.value == Direction.right ? CardModel.CARD_HEIGHT/2 + cardSelectedSpacing + actionToCardSpacing : valNL,
                top: e.value == Direction.top ? CardModel.CARD_HEIGHT/2 + cardSelectedSpacing + actionToCardSpacing : valNB,
                child: Center(
                  child: Container(
                    width: e.value == Direction.left || e.value == Direction.right ? null : wholeCardStackWidth,
                    height: e.value == Direction.left || e.value == Direction.right ? wholeCardStackWidth : null,
                    child: RotatedBox(
                        quarterTurns: turns,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ButtonWidget(
                              textWidget: TextWidget(text: "Pass"),
                              action: (){
                                bool res = murlanState.value.pass(murlanState.value.players[e.key-1]);
                                if(res){
                                  print("Changed");
                                  murlanState.notifyListeners();
                                }
                              },
                            ),
                            ButtonWidget(
                              textWidget: TextWidget(text: "Throw"),
                              action: (){
                                bool res = murlanState.value.throwCards(murlanState.value.players[e.key-1].cards.where((element) => element.selected).toList(), murlanState.value.players[e.key-1]);
                                if(res){
                                  print("Changed");
                                  murlanState.notifyListeners();
                                }
                              },
                            ),
                          ],
                        )
                    ),
                  ),
                )
              ),
              ];
            }).expand((element) => element).toList(),
            ...murlanState.value.table.asMap().entries.map((e) {
              print("${e.key} -> ${e.value}");
              bool foc = e.key == murlanState.value.table.length - 1;
              return Positioned.fill(
                top: 200,
                bottom: 400,
                left: 20,
                right: 20,
                child: Center(
                  child: Transform(
                    transform: Matrix4.zero(),
                    //transform: Matrix4.rotationZ(Random().nextDouble()* 2 * pi),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: e.value.cardsPlayed.map((e) => Container(
                        decoration: BoxDecoration(border: Border.all(color: foc ? Colors.red : Colors.black)),
                        child: e.card
                      )).toList(),
                    )
                  )
                ),
              );
            })
          ],
        );
      },
    );
  }
}
