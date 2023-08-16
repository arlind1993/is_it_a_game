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
          return false;
        }
      }
      return true;
    }else{
      return false;
    }
  }

  bool isBoom(List<CardMurlanModel> cards) =>
      cards.length == 4 && cardCombinationPossible(cards);

  bool cardCombinationColor(List<CardMurlanModel> cards){
    if(cards.length < 5) return false;
    List<int> link = [12, 13, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    List<int> cardsVal = cards.map((e) => e.murlanValue).toList()..sort();
    for(int i = 0; i < cards.length - 1; i++){
      if(cardsVal[i] == cardsVal[i+1]){
        return false;
      }
    }
    for(int i = 0; i < link.length; i++){
      if(link[i] == cardsVal.first){
        int res = search(
          valuesVisited: [],
          link: link,
          chainLeft: cardsVal.where((element) => element != cardsVal.first).toList(),
          pivotInLink: i,
          canGoLeft: true,
          canGoRight: true
        );
        if(res == cards.length){
          return true;
        }
      }
    }
    return false;
  }

  int search({
    required List<int> valuesVisited,
    required List<int> link,
    required List<int> chainLeft,
    required int pivotInLink,
    required bool canGoLeft,
    required bool canGoRight
  }) {
    if(chainLeft.length == 0){
      return valuesVisited.length;
    }
    int? leftPivot = canGoLeft ? (pivotInLink - 1 >= 0 ? pivotInLink - 1 : null) : null;
    int? rightPivot = canGoRight ? (pivotInLink + 1 < link.length ? pivotInLink + 1 : null) : null;
    if(leftPivot == null && rightPivot == null){
      return valuesVisited.length;
    }
    int? leftPivotValue = leftPivot == null ? null : valuesVisited.contains(link[leftPivot])? null:  link[leftPivot];
    int? rightPivotValue = rightPivot == null ? null : valuesVisited.contains(link[rightPivot])? null:  link[rightPivot];
    if(leftPivotValue != null && chainLeft.contains(leftPivotValue)){
      return search(
        valuesVisited: valuesVisited..add(leftPivotValue),
        link: link,
        chainLeft: chainLeft.where((element) => element != leftPivotValue).toList(),
        pivotInLink: leftPivot!,
        canGoLeft: true,
        canGoRight: rightPivotValue != null
      );
    }else if(rightPivotValue != null && chainLeft.contains(leftPivotValue)){
      return search(
        valuesVisited: valuesVisited..add(rightPivotValue),
        link: link,
        chainLeft: chainLeft.where((element) => element != rightPivotValue).toList(),
        pivotInLink: rightPivot!,
        canGoLeft: leftPivotValue != null,
        canGoRight: true
      );
    }else{
      return valuesVisited.length;
    }
  }


  bool throwCards(List<CardMurlanModel> cardsThrown, PlayerMurlanModel player){
    if(!cardCombinationPossible(cardsThrown)) return false;
    TurnMurlanModel? lastTurn;
    for(int i = table.length - 1; i <= 0; i--){
      if(!table[i].passed){
        lastTurn = table[i];
        break;
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