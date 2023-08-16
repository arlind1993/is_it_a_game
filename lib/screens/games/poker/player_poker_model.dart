import 'card_poker_model.dart';

class PlayerPokerModel{
  List<CardPokerModel> cards = [];
  PlayerPokerModel({
    List<CardPokerModel>? importCards,
  }) {
    cards.addAll(importCards ?? []);
  }
}