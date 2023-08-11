import 'card_model.dart';

class PlayerModel{
  List<CardModel> cards = [];
  PlayerModel({
    List<CardModel>? importCards,
  }) {
    this.cards.addAll(importCards ?? []);
  }



}