import 'card_murlan_model.dart';

class TurnMurlanModel{
  int turnCount;
  String playerIdPlayedCards;
  List<CardMurlanModel> cardsPlayed;
  bool get passed => cardsPlayed.isEmpty;

  TurnMurlanModel({
    required this.turnCount,
    required this.playerIdPlayedCards,
    this.cardsPlayed = const []
  });
}