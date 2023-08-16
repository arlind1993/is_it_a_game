import '../../../cards/deck_model.dart';
import 'card_murlan_model.dart';
import 'player_murlan_model.dart';
import 'previous_murlan_game_stats.dart';
import 'turn_murlan_model.dart';

class MurlanState{
  List<Map<String, int>> rankings;
  int playerCount;
  DeckModel deck;
  List<PlayerMurlanModel> players = [];
  List<TurnMurlanModel> table = [];
  MurlanState({
    this.rankings = const [],
    this.playerCount = 4,
    required this.deck,
  }) {
    for(int i = 0; i < playerCount; i++){
      int deckLength = deck.cards.length;
      List<CardMurlanModel> cards = deck.cards.getRange(deckLength - (deckLength ~/ (playerCount - i)), deckLength).map((e) {
        return CardMurlanModel.from(e);
      }).toList();
      cards.sort();
      deck.cards.removeRange(deckLength - (deckLength ~/ (playerCount - i)), deckLength);
      players.add(PlayerMurlanModel(playerId: "pId_$i", importCards: cards));
    }
  }

  bool cardCombinationPossible(List<CardMurlanModel> cards){
    if(cards.isEmpty) {
      return false;
    }else if(cards.length == 1 || cards.length == 2 || cards.length == 3 ||cards.length == 4) {
      int value = cards[0].murlanValue;
      for(int i = 1; i < cards.length; i++){
        if(cards[i].murlanValue != value){
          print("NOs of $value");
          return false;
        }
      }
      print("${cards.length}s of $value");
      return true;
    }else{
      bool res = cardCombinationColor(cards);
      print("Cards are color: $res");
      return res;
    }
  }

  bool isBoom(List<CardMurlanModel> cards) =>
      cards.length == 4 && cardCombinationPossible(cards);

  bool cardCombinationColor(List<CardMurlanModel> cards){
    print("is it a color?");
    if(cards.length < 5) return false;
    List<int> link = [12, 13, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    List<int> cardsVal = cards.map((e) => e.murlanValue).toList()..sort();
    for(int i = 0; i < cards.length - 1; i++){
      if(cardsVal[i] == cardsVal[i+1]){
        print("Same cards selected");
        return false;
      }
    }
    print("Diferent cards selected");
    for(int i = 0; i < link.length; i++){
      print(i);

      if(link[i] == cardsVal.first){
        List<int> valuesVisited = [cardsVal.first];
        List<int> chainLeft = cardsVal.where((element) => element != cardsVal.first).toList();
        int? leftPivot;
        int? rightPivot;
        bool canGoLeft = true;
        bool canGoRight = true;
        int res = 0;
        for(int p = 0; p< link.length*2; p++){
          print("Recursivity: ${[
            valuesVisited,
            link,
            chainLeft,
            leftPivot,
            rightPivot,
            canGoLeft,
            canGoRight]}");
          if(chainLeft.length == 0){
            res = valuesVisited.length;
            break;
          }
          leftPivot = canGoLeft ? ((leftPivot ?? i) - 1 >= 0 ? (leftPivot ?? i) - 1 : null) : null;
          rightPivot = canGoRight ? ((rightPivot ?? i) + 1 < link.length ? (rightPivot ?? i) + 1 : null) : null;
          print("LP: $leftPivot , RP: $rightPivot");
          if(leftPivot == null && rightPivot == null){
            res = valuesVisited.length;
            break;
          }
          int? leftPivotValue = leftPivot == null ? null : valuesVisited.contains(link[leftPivot])? null:  link[leftPivot];
          int? rightPivotValue = rightPivot == null ? null : valuesVisited.contains(link[rightPivot])? null:  link[rightPivot];
          print("LPV: $leftPivotValue , RPV: $rightPivotValue");

          print("CheckL ${chainLeft.contains(leftPivotValue)}");
          print("CheckR ${chainLeft.contains(rightPivotValue)}");
          bool changed = false;
          if(leftPivotValue != null && chainLeft.contains(leftPivotValue)){
            valuesVisited.add(leftPivotValue);
            chainLeft = chainLeft.where((element) => element != leftPivotValue).toList();
            canGoLeft = true;
            changed = true;
          }else{
            canGoLeft = false;
          }
          if(rightPivotValue != null && chainLeft.contains(rightPivotValue)){
            valuesVisited.add(rightPivotValue);
            chainLeft = chainLeft.where((element) => element != rightPivotValue).toList();
            canGoRight = true;
            changed = true;
          }else{
            canGoRight = false;
          }
          if(!changed){
            print("beak here");
            res = valuesVisited.length;
            break;
          }
        }
        if(res == cards.length){
          return true;
        }
      }
    }
    return false;
  }

  bool throwCards(List<CardMurlanModel> cardsThrown, PlayerMurlanModel player){
    print("CardsThrown: ${cardsThrown.map((e) =>
    "${e.numberExtended["string"]}${e.suitExtended["icon"]}")}");
    if(!cardCombinationPossible(cardsThrown)) return false;
    TurnMurlanModel? lastTurn;
    if(table.length >= 1) {
      for (int i = table.length - 1; i <= 0; i--) {
        if (!table[i].passed) {
          lastTurn = table[i];
          break;
        }
      }
    }
    if(lastTurn == null){

    }else{

    }
    return false;
  }
  bool pass(PlayerMurlanModel player){
    table.add(TurnMurlanModel(turnCount: table.isEmpty ? 1 : table.last.turnCount + 1, playerIdPlayedCards: player.playerId));
    return true;
  }



}