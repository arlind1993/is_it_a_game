import 'package:flutter/material.dart';
import 'package:game_template/screens/games/poker/poker_state.dart';
import '../../../cards/card_model.dart';
import '../../../cards/deck_model.dart';
import '../../murlan/widgets/indexer_widget.dart';
enum Direction{
  left,
  right,
  top,
  bottom
}
class PokerPlay extends StatelessWidget {

  ValueNotifier<PokerState> murlanState;
  final double betweenCardsSpacing = 18;
  final double cardSelectedSpacing = 50;
  PokerPlay({
    Key? key,
    int playerCount = 4,
    required DeckModel deck,
  }) : murlanState = ValueNotifier(PokerState(playerCount: playerCount, deck: deck)), super(key: key) {
    assert(murlanState.value.playerCount >= 2 && murlanState.value.playerCount <= 4);
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
              print("${e.value} : ${murlanState.value.players[e.key - 1].cards.length}");
              return Positioned(
                left: e.value == Direction.left ? -CardModel.CARD_SIZE.height/2 : e.value != Direction.right ? 0 : null,
                bottom: e.value == Direction.bottom ? -CardModel.CARD_SIZE.height/2 :  e.value != Direction.top ? 0 : null,
                right: e.value == Direction.right ? -CardModel.CARD_SIZE.height/2 :  e.value != Direction.left ? 0 : null,
                top: e.value == Direction.top ? -CardModel.CARD_SIZE.height/2 :  e.value != Direction.bottom ? 0 : null,
                child: Center(
                  child: Builder(
                    builder: (context) {
                      return Indexer(
                        children: List.generate(murlanState.value.players[e.key-1].cards.length, (index) {
                          print("EdgeInsets.only(\n"
                              "left: ${e.value} == left && ${murlanState.value.players[e.key-1].cards[index].selected} ? 20 : ${e.value} == Direction.bottom ? ${index * 10} : 0, => ${e.value == Direction.left && murlanState.value.players[e.key-1].cards[index].selected ? 20 : e.value == Direction.bottom || e.value == Direction.top? index * 20 : 0}\n"
                              "bottom: ${e.value} == bottom && ${murlanState.value.players[e.key-1].cards[index].selected} ? 20 : 0, => ${e.value == Direction.bottom && murlanState.value.players[e.key-1].cards[index].selected ? 20 : 0}\n"
                              "right: ${e.value} == right && ${murlanState.value.players[e.key-1].cards[index].selected} ? 20 : 0, => ${e.value == Direction.right && murlanState.value.players[e.key-1].cards[index].selected ? 20 : 0}\n"
                              "top: ${e.value} == top && ${murlanState.value.players[e.key-1].cards[index].selected} ? 20 : ${e.value} == Direction.left ? ${index * 10} : 0, => ${e.value == Direction.top && murlanState.value.players[e.key-1].cards[index].selected ? 20 : e.value == Direction.left || e.value == Direction.right ? index * 20 : 0}\n"
                              "),");

                          double width = (e.value == Direction.top || e.value == Direction.bottom) ? CardModel.CARD_SIZE.width : CardModel.CARD_SIZE.width;
                          double height = (e.value == Direction.top || e.value == Direction.bottom) ? CardModel.CARD_SIZE.height : CardModel.CARD_SIZE.height;
                          double left = 0;
                          double top = 0;

                          int turns = 0;
                          if(e.value == Direction.left){
                            turns = 1;
                          }else if(e.value == Direction.top){
                            turns = 2;
                          }else if(e.value == Direction.right){
                            turns = 3;
                          }
                          print(turns);

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
                                print(details);
                                murlanState.value.players[e.key-1].cards[index].toggle();
                                murlanState.notifyListeners();
                              },
                              onTapDown: (details) {
                                print(details);
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
                                  child: murlanState.value.players[e.key-1].cards[index]
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    }
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
