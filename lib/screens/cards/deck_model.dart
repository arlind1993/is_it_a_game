import 'package:game_template/screens/cards/card_model.dart';

class DeckModel {
  bool withJacks;
  List<CardModel> cards;
  DeckModel({
    this.withJacks = true,
  }): cards = [
    if(withJacks) ...[CardModel(number: 15, suit: 0), CardModel(number: 14, suit: 0)],
    ...List.generate(13 * 4, (index) => CardModel(number: index % 4 + 1, suit: index ~/ 4 + 1))
  ]{
    cards.shuffle();
  }
}