import 'package:game_template/screens/cards/card_model.dart';

class CardMurlanModel extends CardModel implements Comparable<CardMurlanModel>{
  static int toMurlanValue(int value){
    switch(value){
      case 1: return 12;
      case 2: return 13;
      case 3: return 1;
      case 4: return 2;
      case 5: return 3;
      case 6: return 4;
      case 7: return 5;
      case 8: return 6;
      case 9: return 7;
      case 10: return 8;
      case 11: return 9;
      case 12: return 10;
      case 13: return 11;
      case 14: return 14;
      case 15: return 15;
      default: throw "value not in bound";
    }
  }

  bool selected;
  int murlanValue;

  CardMurlanModel({required super.number, required super.suit, this.selected = false}): murlanValue = toMurlanValue(number);
  factory CardMurlanModel.from(CardModel cardModel) => CardMurlanModel(number: cardModel.number, suit: cardModel.suit);
  factory CardMurlanModel.clone(CardMurlanModel cardMurlanModel) => CardMurlanModel(number: cardMurlanModel.number, suit: cardMurlanModel.suit, selected: cardMurlanModel.selected);

  void toggle(){
    selected = !selected;
  }

  @override
  int compareTo(CardMurlanModel other) {
    return murlanValue - other.murlanValue;
  }
}