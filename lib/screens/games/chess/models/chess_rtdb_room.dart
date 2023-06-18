import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import 'chess_rtdb_moves.dart';

class ChessRoomModel{
  String room_id;
  String starting_position;
  String? player_white_id;
  String? player_black_id;
  List<ChessMovesModel>? moves;
  ChessRoomModel({
    required this.room_id,
    required this.starting_position,
    this.player_white_id,
    this.player_black_id,
    this.moves
  });

  @override
  bool operator ==(Object other) {
    return other is ChessRoomModel
    && room_id == other.room_id
    && starting_position == other.starting_position
    && player_white_id == other.player_white_id
    && player_black_id == other.player_black_id
    && listEquals(moves, other.moves);
  }


  factory ChessRoomModel.fromJson(Map<String, dynamic> jsonData) {
    if(jsonData["room_id"] is String
        && jsonData["starting_position"] is String
        && (jsonData["player_white_id"] is String || jsonData["player_white_id"] == null)
        && (jsonData["player_black_id"] is String || jsonData["player_black_id"] == null)
        && (jsonData["moves"] is List || jsonData["moves"] == null)
    ){
      List<ChessMovesModel>? moves;
      if(jsonData["moves"] is List){
        moves = (jsonData["moves"] as List).map((e){
          if(e is! ChessMovesModel){
            try{
              return ChessMovesModel.fromJson(e);
            }catch(e){
              print(e);
            }
          }
          return e;
        }).whereType<ChessMovesModel>().toList();
      }

      return ChessRoomModel(
        room_id: jsonData["room_id"] as String,
        starting_position: jsonData["starting_position"] as String,
        player_white_id: jsonData["player_white_id"] is String ? jsonData["player_white_id"] as String : null,
        player_black_id: jsonData["player_black_id"] is String ? jsonData["player_black_id"] as String : null,
        moves: moves,
      );
    }
    throw "JsonData to Model wasn't transformed, \n"
      "Problem ->${{
        "room_id" : jsonData["room_id"] is String,
        "starting_position" : jsonData["starting_position"] is String,
        "player_white_id" : (jsonData["player_white_id"] is String || jsonData["player_white_id"] == null),
        "player_black_id" : (jsonData["player_black_id"] is String || jsonData["player_black_id"] == null),
        "moves" : (jsonData["moves"] is List || jsonData["moves"] == null)
      }}";
  }

  factory ChessRoomModel.fromRTDB(DataSnapshot snapshot) {
    if(snapshot.child("room_id").value is String
        && snapshot.child("starting_position").value is String
        && (snapshot.child("player_white_id").value is String || snapshot.child("player_white_id").value == null)
        && (snapshot.child("player_black_id").value is String || snapshot.child("player_black_id").value == null)
        && (snapshot.child("moves").value is List || snapshot.child("moves").value == null)
    ){
      List<ChessMovesModel>? moves;
      if(snapshot.child("moves").value is List){
        moves = (snapshot.child("moves").value as List).map((e){
          if(e is! ChessMovesModel){
            try{
              return ChessMovesModel.fromJson(e);
            }catch(e){
              print(e);
            }
          }
          return e;
        }).whereType<ChessMovesModel>().toList();
      }

      return ChessRoomModel(
        room_id: snapshot.child("room_id").value as String,
        starting_position: snapshot.child("starting_position").value as String,
        player_white_id: snapshot.child("player_white_id").value is String ? snapshot.child("player_white_id").value as String : null,
        player_black_id: snapshot.child("player_black_id").value is String ? snapshot.child("player_black_id").value as String : null,
        moves: moves,
      );
    }
    throw "JsonData to Model wasn't transformed, \n"
        "Problem ->${{
      "roomId" : snapshot.child("room_id").value is String,
      "startingPosition" : snapshot.child("starting_position").value is String,
      "playerWhiteId" : (snapshot.child("player_white_id").value is String || snapshot.child("player_white_id").value == null),
      "playerBlackId" : (snapshot.child("player_black_id").value is String || snapshot.child("player_black_id").value == null),
      "moves" : (snapshot.child("moves").value is List || snapshot.child("moves").value == null)
    }}";
  }

  Map<String, dynamic> toJson() => {
    "room_id": room_id,
    "starting_position": starting_position,
    "player_white_id": player_white_id,
    "player_black_id": player_black_id,
    "moves": moves,
  };

  @override
  String toString() {
    return toJson().toString();
  }
}