import 'package:game_template/screens/cards/card_model.dart';

class DeckModel {
  final bool withJacks;
  final int totalDecks;
  final List<CardModel> cards;
  CardType cardType;

  static List<CardModel> cardGenerator(int totalDecks, bool withJacks, bool shuffled, CardType cardType){
    List<CardModel> cards = [];
    for(int i = 0; i< totalDecks; i++){
      if(withJacks){
        cards.add(CardModel(number: 15, suit: 0, cardType: cardType));
        cards.add(CardModel(number: 14, suit: 0, cardType: cardType));
      }
      for(int suit = 1; suit <= 4; suit++){
        for(int number = 1; number <= 13; number++){
          cards.add(CardModel(number: number, suit: suit, cardType: cardType));
        }
      }
    }
    if(shuffled){
      cards.shuffle();
    }
    return cards;
  }

  DeckModel({
    required this.cardType,
    this.totalDecks = 1,
    this.withJacks = true,
    bool shuffled = true,
  }):cards = cardGenerator(totalDecks, withJacks, shuffled, cardType);
}