import '../../cards/deck_model.dart';
import 'card_murlan_model.dart';
import 'player_murlan_model.dart';

class MurlanState{
  int playerCount;
  DeckModel deck;
  List<PlayerMurlanModel> players = [];
  List<CardMurlanModel> table = [];
  MurlanState({
    this.playerCount = 4,
    required this.deck,
  }) {
    for(int i = 0; i < playerCount; i++){
      int deckLength = deck.cards.length;
      List<CardMurlanModel> cards = deck.cards.getRange(deckLength - (deckLength ~/ (playerCount - i)), deckLength).map((e) => CardMurlanModel.from(e)).toList();
      deck.cards.removeRange(deckLength - (deckLength ~/ (playerCount - i)), deckLength);
      players.add(PlayerMurlanModel(importCards: cards));
    }
  }
}