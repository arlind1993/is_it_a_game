import 'package:flutter/cupertino.dart';

enum Suit{
  none,
  spades,
  diamonds,
  clubs,
  hearts,
}
enum Number{
  ace,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  ten,
  jack,
  queen,
  king,
  blackJoker,
  redJoker,
}

extension NumberExtension on Number{
  Map<String, dynamic> get extended{
    switch(this){
      case Number.ace: return {
        "value": 1,
        "string": "A",
        "number": this,
      };
      case Number.two: return {
        "value": 2,
        "string": "2",
        "number": this,
      };
      case Number.three: return {
        "value": 3,
        "string": "3",
        "number": this,
      };
      case Number.four: return {
        "value": 4,
        "string": "4",
        "number": this,
      };
      case Number.five: return {
        "value": 5,
        "string": "5",
        "number": this,
      };
      case Number.six: return {
        "value": 6,
        "string": "6",
        "number": this,
      };
      case Number.seven: return {
        "value": 7,
        "string": "7",
        "number": this,
      };
      case Number.eight: return {
        "value": 8,
        "string": "8",
        "number": this,
      };
      case Number.nine: return {
        "value": 9,
        "string": "9",
        "number": this,
      };
      case Number.ten: return {
        "value": 10,
        "string": "♠",
        "number": this,
      };
      case Number.jack: return {
        "value": 11,
        "string": "J",
        "number": this,
      };
      case Number.queen: return {
        "value": 12,
        "string": "Q",
        "number": this,
      };
      case Number.king: return {
        "value": 13,
        "string": "K",
        "number": this,
      };
      case Number.blackJoker: return {
        "value": 14,
        "string": "BJ",
        "number": this,
      };
      case Number.redJoker: return {
        "value": 15,
        "string": "RJ",
        "number": this,
      };
    }
  }
  static Map<String, dynamic> getExtended(int value){
    switch(value){
      case 1: return {
        "value": value,
        "string": "A",
        "number": Number.ace,
      };
      case 2: return {
        "value": value,
        "string": "2",
        "number": Number.two,
      };
      case 3: return {
        "value": value,
        "string": "3",
        "number": Number.three,
      };
      case 4: return {
        "value": value,
        "string": "4",
        "number": Number.four,
      };
      case 5: return {
        "value": value,
        "string": "5",
        "number": Number.five,
      };
      case 6: return {
        "value": value,
        "string": "6",
        "number": Number.six,
      };
      case 7: return {
        "value": value,
        "string": "7",
        "number": Number.seven,
      };
      case 8: return {
        "value": value,
        "string": "8",
        "number": Number.eight,
      };
      case 9: return {
        "value": value,
        "string": "9",
        "number": Number.nine,
      };
      case 10: return {
        "value": value,
        "string": "♠",
        "number": Number.ten,
      };
      case 11: return {
        "value": value,
        "string": "J",
        "number": Number.jack,
      };
      case 12: return {
        "value": value,
        "string": "Q",
        "number": Number.queen,
      };
      case 13: return {
        "value": value,
        "string": "K",
        "number": Number.king,
      };
      case 14: return {
        "value": value,
        "string": "BJ",
        "number": Number.blackJoker,
      };
      case 15: return {
        "value": value,
        "string": "RJ",
        "number": Number.redJoker,
      };
      default: throw "not possible value";
    }
  }
}
extension SuitExtension on Suit{
  Map<String, dynamic> get extended {
    switch(this){
      case Suit.none: return {
        "value": 0,
        "icon": " ",
        "suit": this,
      };
      case Suit.spades: return {
        "value": 1,
        "icon": "♠",
        "suit": this,
      };
      case Suit.diamonds: return {
        "value": 2,
        "icon": "♦",
        "suit": this,
      };
      case Suit.clubs: return {
        "value": 3,
        "icon": "♣",
        "suit": this,
      };
      case Suit.hearts: return {
        "value": 4,
        "icon": "♥",
        "suit": this,
      };
    }
  }
  static Map<String, dynamic> getExtended(int value){
    switch(value){
      case 0: return {
        "value": value,
        "icon": "  ",
        "suit": Suit.none,
      };
      case 1: return {
        "value": value,
        "icon": "♠",
        "suit": Suit.spades,
      };
      case 2: return {
        "value": value,
        "icon": "♦",
        "suit": Suit.diamonds,
      };
      case 3: return {
        "value": value,
        "icon": "♣",
        "suit": Suit.clubs,
      };
      case 4: return {
        "value": value,
        "icon": "♥",
        "suit": Suit.hearts,
      };
      default: throw "non valid Value";
    }
  }
}

class CardModel{
  int number;
  int suit;
  late Widget card;

  Map<String, dynamic> get numberExtended => NumberExtension.getExtended(number);
  Map<String, dynamic> get suitExtended => SuitExtension.getExtended(number);
  CardModel({
    required this.number,
    required this.suit
  }){
    card = Container();
  }

}