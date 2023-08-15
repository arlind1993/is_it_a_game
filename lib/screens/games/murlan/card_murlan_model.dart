import 'package:game_template/screens/cards/card_model.dart';

class CardMurlanModel extends CardModel{
  bool selected;
  CardMurlanModel({required super.number, required super.suit, this.selected = false});

  factory CardMurlanModel.from(CardModel cardModel) => CardMurlanModel(number: cardModel.number, suit: cardModel.suit);
  void toggle(){
    selected = !selected;
  }
}