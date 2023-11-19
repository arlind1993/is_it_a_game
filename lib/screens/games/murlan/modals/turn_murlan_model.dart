import 'dart:math';
import 'dart:ui';

import 'card_murlan_model.dart';

class TurnMurlanModel{
  int turnCount;
  String playerIdPlayedCards;
  List<CardMurlanModel> cardsPlayed;
  bool get passed => cardsPlayed.isEmpty;
  double angled;
  Offset dxdy;

  TurnMurlanModel({
    required this.turnCount,
    required this.playerIdPlayedCards,
    this.cardsPlayed = const []
  }): angled = Random().nextDouble() * 2 * pi,
      dxdy = Offset(Random().nextDouble() * 10, Random().nextDouble() * 20);

  @override
  String toString() {
    return {
      "turnCount": turnCount,
      "playerIdPlayedCards": playerIdPlayedCards,
      "cardsPlayed": cardsPlayed,
      "passed": passed,
    }.toString();
  }
}