import '../../../cards/card_model.dart';

class MurlanPlayerModel{
  String playerId;
  List<CardModel> cards;
  int initCount;
  MurlanPlayerModel({
    required this.playerId,
    this.cards = const[],
  }): initCount = cards.length;
}