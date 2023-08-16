import 'package:game_template/screens/cards/card_model.dart';

class CardPokerModel extends CardModel{
  bool selected;
  CardPokerModel({required super.number, required super.suit, this.selected = false});

  factory CardPokerModel.from(CardModel cardModel) => CardPokerModel(number: cardModel.number, suit: cardModel.suit);
  void toggle(){
    selected = !selected;
  }
}