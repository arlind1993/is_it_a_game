import 'card_murlan_model.dart';

class PlayerMurlanModel{
  String playerId;
  List<CardMurlanModel> cards;
  int initCount;
  PlayerMurlanModel({
    required this.playerId,
    this.cards = const[],
  }): initCount = cards.length;
}