import 'package:flutter/material.dart';

import '../../../cards/card_model.dart';
import '../../../cards/deck_model.dart';
import '../../../cards/player_model.dart';

class MurlanPlay extends StatelessWidget {
  int playerCount;
  DeckModel deck;
  List<PlayerModel> players = [];
  MurlanPlay({
    Key? key,
    this.playerCount = 4,
    required this.deck,
  }) : super(key: key){
    for(int i = 0; i < playerCount; i++){
      int deckLength = deck.cards.length;
      List<CardModel> cards = deck.cards.getRange(deckLength - (deckLength ~/ (playerCount - i)), deckLength).toList();
      deck.cards.removeRange(deckLength - (deckLength ~/ (playerCount - i)), deckLength);
      players.add(PlayerModel(importCards: cards));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
