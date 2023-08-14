import 'package:game_template/screens/cards/card_model.dart';

class DeckModel {
  bool withJacks;
  List<CardModel> cards;
  DeckModel({
    this.withJacks = true,
  }): cards = [
    if(withJacks) ...[CardModel(number: 15, suit: 0), CardModel(number: 14, suit: 0)],
    ...List.generate(13 * 4, (index) {
      return CardModel(number: (index % 13) + 1, suit: (index ~/ 13) + 1);
    })
  ]{
    cards.shuffle();
  }
}