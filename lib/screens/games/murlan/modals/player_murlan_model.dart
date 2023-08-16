import 'card_murlan_model.dart';

class PlayerMurlanModel{
  String playerId;
  List<CardMurlanModel> cards = [];
  PlayerMurlanModel({
    required this.playerId,
    List<CardMurlanModel>? importCards,
  }) {
    cards.addAll(importCards ?? []);
  }
}