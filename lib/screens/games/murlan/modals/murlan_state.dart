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
  late String playerTurn;
  MapEntry<CardMurlanModel, CardMurlanModel>? exchangedCards;
  MurlanState({
    this.rankings = const [],
    this.playerCount = 4,
    required this.deck,
  }) {
    String? p;
    if(rankings.isNotEmpty){
      p = rankings.last.keys.last;
    }
    for(int i = 0; i < playerCount; i++){
      int deckLength = deck.cards.length;
      List<CardMurlanModel> cards = deck.cards.getRange(deckLength - (deckLength ~/ (playerCount - i)), deckLength).map((e) {
        return CardMurlanModel.from(e);
      }).toList();
      cards.sort();
      if(p == null && cards.any((element) => element.number == 3 && element.suit == 1)){
        p = "pId_$i";
      }
      deck.cards.removeRange(deckLength - (deckLength ~/ (playerCount - i)), deckLength);
      players.add(PlayerMurlanModel(playerId: "pId_$i", importCards: cards));
    }
    playerTurn = p!;
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

  bool isBoom(List<CardMurlanModel> cards) => isCombinedOfNs(cards, 4);

  bool isCombinedOfNs(List<CardMurlanModel> cards, int number){
    assert(number >= 1 && number <= 4);
    return cards.length == number && cardCombinationPossible(cards);
  }

  bool cardCombinationColor(List<CardMurlanModel> cards, {bool sort = true, isFlush = false}){
    print("is it a color?");
    if(cards.length < 5) return false;
    List<int> link = [12, 13, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    List<int> cardsVal = cards.map((e) => e.murlanValue).toList();
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
        int pivotMin = i;
        int pivotMax = i;
        bool canGoLeft = true;
        bool canGoRight = true;
        int res = 0;
        for(int p = 0; p < link.length; p++){
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
            pivotMin = leftPivot!;
            valuesVisited.add(leftPivotValue);
            chainLeft = chainLeft.where((element) => element != leftPivotValue).toList();
            canGoLeft = true;
            changed = true;
          }else{
            canGoLeft = false;
          }
          if(rightPivotValue != null && chainLeft.contains(rightPivotValue)){
            pivotMax = rightPivot!;
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
          if(isFlush && cards.any((element) => element.suit != cards.first.suit)){
            continue;
          }
          if(sort){
            print("PMin ->$pivotMin, PMax ->$pivotMax");
            for(int i = 0; i <= pivotMax-pivotMin; i++){
              print("Sorted cards: $cards for pos $i -> ${link[pivotMin + i]}");
              for(int j = i + 1; j < cards.length; j++){
                if(cards[j].murlanValue == link[pivotMin + i]){
                  CardMurlanModel temp = cards[i];
                  cards[i] = cards[j];
                  cards[j] = temp;
                }
              }
            }
            print("Sorted cards: $cards");
          }
          return true;
        }
      }
    }
    return false;
  }

  bool throwCards(List<CardMurlanModel> cardsThrown, PlayerMurlanModel player){
    print("CardsThrown: $cardsThrown");
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
      print("No last turn");
      if(cardsThrown.any((element) => element.number == 3 && element.suit == 1)){
        player.cards.removeWhere((element) => cardsThrown.contains(element));
        return addToTable(table, player, cardsThrown);
      }
    }else{
      bool lastTurnWasFlush = cardCombinationColor(lastTurn.cardsPlayed, isFlush: true);
      bool lastTurnWasBoom = isBoom(lastTurn.cardsPlayed);
      if(cardCombinationColor(cardsThrown, isFlush: true)){
        if(lastTurnWasFlush){
          if(lastTurn.cardsPlayed.length == cardsThrown.length && (lastTurn.cardsPlayed.first.murlanValue == 13 ? 0: lastTurn.cardsPlayed.first.murlanValue) + 1 == cardsThrown.first.murlanValue){
            return addToTable(table, player, cardsThrown);
          }
        }else {
          return addToTable(table, player, cardsThrown);
        }
      }
      if(lastTurnWasFlush){
        return false;
      }
      if(isBoom(cardsThrown)){
        if(lastTurnWasBoom){
          if(lastTurn.cardsPlayed.first.murlanValue < cardsThrown.first.murlanValue){
            return addToTable(table, player, cardsThrown);
          }
        }else {
          return addToTable(table, player, cardsThrown);
        }
      }
      if(lastTurnWasBoom){
        return false;
      }

      if(cardCombinationColor(lastTurn.cardsPlayed)){
        if(cardCombinationColor(cardsThrown)){
          if(lastTurn.cardsPlayed.length == cardsThrown.length && (lastTurn.cardsPlayed.first.murlanValue == 13 ? 0: lastTurn.cardsPlayed.first.murlanValue) + 1 == cardsThrown.first.murlanValue){
            return addToTable(table, player, cardsThrown);
          }
        }
      }

      if(lastTurn.cardsPlayed.length >= 1 && lastTurn.cardsPlayed.length <= 3){
        int fullNo = lastTurn.cardsPlayed.length;
        if(isCombinedOfNs(cardsThrown, fullNo)){
          if(lastTurn.cardsPlayed.first.murlanValue < cardsThrown.first.murlanValue){
            return addToTable(table, player, cardsThrown);
          }
        }
      }
    }
    return false;
  }

  bool addToTable(List<TurnMurlanModel> table, PlayerMurlanModel player, List<CardMurlanModel> cardsToThrow){
    table.add(
      TurnMurlanModel(
        turnCount: table.isEmpty ? 1 : table.last.turnCount + 1,
        playerIdPlayedCards: player.playerId,
        cardsPlayed: cardsToThrow
      )
    );
    print(table);
    print(this.table);
    print("Add to table -> $cardsToThrow");
    return nextTurn();
  }

  bool pass(PlayerMurlanModel player){
    table.add(
      TurnMurlanModel(
        turnCount: table.isEmpty ? 1 : table.last.turnCount + 1,
        playerIdPlayedCards: player.playerId
      )
    );

    print("Pass ->");
    return nextTurn();
  }

  bool nextTurn(){
    int index = -1;
    for(int i = 0; i< players.length; i++){
      if(players[i].playerId == playerTurn){
        index = i;
      }
    }

    if(index == -1) return false;
    for(int i = 0; i< players.length; i++){
      int nextIndex = (index + i + 1) % players.length;
      if(players[nextIndex].cards.isNotEmpty){
        playerTurn = players[nextIndex].playerId;
        return true;
      }
    }

    return false;
  }



}