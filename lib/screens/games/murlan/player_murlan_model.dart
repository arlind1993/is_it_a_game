import 'package:game_template/screens/games/murlan/card_murlan_model.dart';

import '../../cards/card_model.dart';

class PlayerMurlanModel{
  List<CardMurlanModel> cards = [];
  PlayerMurlanModel({
    List<CardMurlanModel>? importCards,
  }) {
    cards.addAll(importCards ?? []);
  }
}