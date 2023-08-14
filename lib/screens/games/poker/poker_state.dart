import '../../cards/card_model.dart';
import '../../cards/deck_model.dart';
import '../../cards/player_model.dart';

class PokerState{
  int playerCount;
  DeckModel deck;
  List<PlayerModel> players = [];
  List<CardModel> table = [];
  PokerState({
    this.playerCount = 4,
    required this.deck,
  }) {
    for(int i = 0; i < playerCount; i++){
      int deckLength = deck.cards.length;
      List<CardModel> cards = deck.cards.getRange(deckLength - (deckLength ~/ (playerCount - i)), deckLength).toList();
      deck.cards.removeRange(deckLength - (deckLength ~/ (playerCount - i)), deckLength);
      players.add(PlayerModel(importCards: cards));
    }
  }
}