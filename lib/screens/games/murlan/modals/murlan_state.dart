import 'package:flutter/cupertino.dart';
import 'package:game_template/screens/cards/card_model.dart';
import '../../../cards/deck_model.dart';
import 'murlan_player_model.dart';
import 'turn_murlan_model.dart';

class MurlanState{
  ValueNotifier<String?> currentError = ValueNotifier(null);
  List<Map<String, int>> rankings;
  DeckModel deck;
  List<MurlanPlayerModel> players = [];
  List<TurnMurlanModel> tableState = [];
  late String playerTurn;
  MapEntry<CardModel, CardModel>? exchangedCards;
  final int playerCount;

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
      List<CardModel> cards = deck.cards.getRange(deckLength - (deckLength ~/ (playerCount - i)), deckLength).toList();
      cards.sort((a, b) => a.actualValue - b.actualValue,);
      if(p == null && cards.any((element) => element.number == 3 && element.suit == 1)){
        p = "pId_$i";
      }
      deck.cards.removeRange(deckLength - (deckLength ~/ (playerCount - i)), deckLength);
      players.add(MurlanPlayerModel(playerId: "pId_$i", cards: cards));
    }
    playerTurn = p!;
  }

  setErrorValue(String? value){
    print("setErrorValue($value)");
    if(currentError.value == value){
      currentError.notifyListeners();
    }else{
      currentError.value = value;
    }
  }

  bool cardCombinationPossible(List<CardModel> cards){
    if(cards.isEmpty) {
      setErrorValue("No cards were selected");
      return false;
    }else if(cards.length == 1 || cards.length == 2 || cards.length == 3 ||cards.length == 4) {
      int value = cards[0].actualValue;
      for(int i = 1; i < cards.length; i++){
        if(cards[i].actualValue != value){
          setErrorValue("All the selected cards have to be the same");
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

  bool isBoom(List<CardModel> cards) => isCombinedOfNs(cards, 4);

  bool isCombinedOfNs(List<CardModel> cards, int number){
    assert(number >= 1 && number <= 4);
    return cards.length == number && cardCombinationPossible(cards);
  }

  bool cardCombinationColor(List<CardModel> cards, {bool sort = true, isFlush = false}){
    print("is it a color?");
    if(cards.length < 5) return false;
    List<int> link = [12, 13, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    List<int> cardsVal = cards.map((e) => e.actualValue).toList();
    for(int i = 0; i < cards.length - 1; i++){
      if(cardsVal[i] == cardsVal[i+1]){
        setErrorValue("The Color combination can't have 2 of the same cards");
        return false;
      }
    }
    print("Different cards selected");
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
                if(cards[j].actualValue == link[pivotMin + i]){
                  CardModel temp = cards[i];
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
    if(isFlush){
      setErrorValue("The selected cards are not consecutive or not a flush");
    }else{
      setErrorValue("The selected cards are not consecutive");
    }
    return false;
  }

  bool throwCards(List<CardModel> cardsThrown, MurlanPlayerModel player){
    print("CardsThrown: $cardsThrown");
    print(tableState);
    if(!cardCombinationPossible(cardsThrown)) return false;
    MapEntry<int, TurnMurlanModel>? lastTurn;
    if(tableState.isNotEmpty) {
      for (int i = tableState.length - 1; i >= 0; i--) {
        if (!tableState[i].passed) {
          lastTurn = MapEntry(i, tableState[i]);
          break;
        }
      }
    }
    print("last turn $lastTurn");
    if(lastTurn == null){
      if(rankings.isEmpty){
        if(cardsThrown.any((element) => element.number == 3 && element.suit == 1)) {
          return addToTable(tableState, player, cardsThrown);
        }else{
          setErrorValue("The selected cards must contain a 3♠ (three of spades)");
        }
      }else{
        if(playerTurn == rankings.last.keys.last){
          return addToTable(tableState, player, cardsThrown);
        }
      }
    }else if(lastTurn.value.playerIdPlayedCards == playerTurn || allPassedForNextPlayerTurn(lastTurn, tableState, player)){
      return addToTable(tableState, player, cardsThrown);
    }else{
      bool lastTurnWasFlush = cardCombinationColor(lastTurn.value.cardsPlayed, isFlush: true);
      bool lastTurnWasBoom = isBoom(lastTurn.value.cardsPlayed);
      if(cardCombinationColor(cardsThrown, isFlush: true)){
        if(lastTurnWasFlush){
          if(lastTurn.value.cardsPlayed.length == cardsThrown.length && (lastTurn.value.cardsPlayed.first.actualValue == 13 ? 0: lastTurn.value.cardsPlayed.first.actualValue) + 1 == cardsThrown.first.actualValue){
            return addToTable(tableState, player, cardsThrown);
          }
        }else {
          return addToTable(tableState, player, cardsThrown);
        }
      }
      if(lastTurnWasFlush){
        setErrorValue("The selected cards are not a flush or can't beat last flush");
        return false;
      }
      if(isBoom(cardsThrown)){
        if(lastTurnWasBoom){
          if(lastTurn.value.cardsPlayed.first.actualValue < cardsThrown.first.actualValue){
            return addToTable(tableState, player, cardsThrown);
          }
        }else {
          return addToTable(tableState, player, cardsThrown);
        }
      }
      if(lastTurnWasBoom){
        setErrorValue("The selected cards can't beat last boom");
        return false;
      }

      if(cardCombinationColor(lastTurn.value.cardsPlayed)){
        if(cardCombinationColor(cardsThrown)){
          if(lastTurn.value.cardsPlayed.length == cardsThrown.length && (lastTurn.value.cardsPlayed.first.actualValue == 13 ? 0: lastTurn.value.cardsPlayed.first.actualValue) + 1 == cardsThrown.first.actualValue){
            return addToTable(tableState, player, cardsThrown);
          }else{
            setErrorValue("The selected cards can't beat last color");
          }
        }
      }

      if(lastTurn.value.cardsPlayed.length >= 1 && lastTurn.value.cardsPlayed.length <= 3){
        int fullNo = lastTurn.value.cardsPlayed.length;
        if(isCombinedOfNs(cardsThrown, fullNo)){
          if(lastTurn.value.cardsPlayed.first.actualValue < cardsThrown.first.actualValue){
            return addToTable(tableState, player, cardsThrown);
          }else{
            setErrorValue("The selected cards can't beat last cards thrown");
          }
        }else{
          setErrorValue("The selected cards aren't of same length as last cards thrown");
        }
      }
    }
    return false;
  }

  bool addToTable(List<TurnMurlanModel> table, MurlanPlayerModel player, List<CardModel> cardsToThrow){
    player.cards.removeWhere((element) => cardsToThrow.contains(element));
    table.add(
      TurnMurlanModel(
        turnCount: table.isEmpty ? 1 : table.last.turnCount + 1,
        playerIdPlayedCards: player.playerId,
        cardsPlayed: cardsToThrow
      )
    );
    print(table);
    print(this.tableState);
    print("Add to table -> $cardsToThrow");
    return nextTurn();
  }

  bool pass(MurlanPlayerModel player){
    MapEntry<int, TurnMurlanModel>? lastTurn;
    if(tableState.isNotEmpty) {
      for (int i = tableState.length - 1; i >= 0; i--) {
        if (!tableState[i].passed) {
          lastTurn = MapEntry(i, tableState[i]);
          break;
        }
      }
    }
    if(lastTurn == null){
      if(rankings.isEmpty){
        setErrorValue("Its your turn you can't pass it up as you contain a 3♠");
        return false;
      }else{
        if(playerTurn == rankings.last.keys.last){
          setErrorValue("Its your turn as you were place last last game");
          return false;
        }
      }
    }else{
      if(lastTurn.value.playerIdPlayedCards == playerTurn){
        setErrorValue("Its your free turn, you can play whichever card");
        return false;
      }else if(allPassedForNextPlayerTurn(lastTurn, tableState, player)){
        setErrorValue("Its your free turn, as everybody passed, you can play whichever card");
        return false;
      }
    }

    tableState.add(
      TurnMurlanModel(
        turnCount: tableState.isEmpty ? 1 : tableState.last.turnCount + 1,
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
        players[i].cards.forEach((element) => element.isCardSelected = false);
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

  bool allPassedForNextPlayerTurn(MapEntry<int, TurnMurlanModel> lastTurn, List<TurnMurlanModel> table, MurlanPlayerModel player) {
    bool lastTurnPlayerWithoutCards = false;
    int playersWithCards = 0;
    for(int i = 0; i < players.length; i++){
      if(players[i].playerId == lastTurn.value.playerIdPlayedCards){
        lastTurnPlayerWithoutCards = true;
      }
      if(players[i].cards.isNotEmpty){
        playersWithCards++;
      }
    }
    if(!lastTurnPlayerWithoutCards || playersWithCards == 0) return false;
    return playersWithCards == table.length - 1 - lastTurn.key;
  }



}