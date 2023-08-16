import '../../cards/card_model.dart';
import '../../cards/deck_model.dart';
import 'card_poker_model.dart';
import 'player_poker_model.dart';

class PokerState{
  int playerCount;
  DeckModel deck;
  List<PlayerPokerModel> players = [];
  List<CardPokerModel> table = [];
  PokerState({
    this.playerCount = 4,
    required this.deck,
  }) {
    for(int i = 0; i < playerCount; i++){
      int deckLength = deck.cards.length;
      List<CardPokerModel> cards = deck.cards.getRange(deckLength - (deckLength ~/ (playerCount - i)), deckLength).map((e) => CardPokerModel.from(e)).toList();
      deck.cards.removeRange(deckLength - (deckLength ~/ (playerCount - i)), deckLength);
      players.add(PlayerPokerModel(importCards: cards));
    }
  }
}