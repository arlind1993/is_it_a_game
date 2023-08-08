import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import 'sudoku_move.dart';

class SudokuRoomModel{
  String room_id;
  String starting_position;
  List<SudokuMove> moves;
  SudokuRoomModel({
    required this.room_id,
    required this.starting_position,
    required this.moves,
  });

  @override
  bool operator ==(Object other) {
    return other is SudokuRoomModel
    && room_id == other.room_id
    && starting_position == other.starting_position
    && listEquals(moves, other.moves);
  }


  factory SudokuRoomModel.fromJson(Map<String, dynamic> jsonData) {
    if(jsonData["room_id"] is String
        && jsonData["starting_position"] is String && (jsonData["moves"] is List || jsonData["moves"] == null)
    ){
      List<SudokuMove> moves = [];
      if(jsonData["moves"] is List){
        moves = (jsonData["moves"] as List).map((e){
          if(e is! SudokuMove){
            try{
             // return SudokuMove.fromJson(e);
            }catch(e){
              print(e);
            }
          }
          return e;
        }).whereType<SudokuMove>().toList();
      }

      return SudokuRoomModel(
        room_id: jsonData["room_id"] as String,
        starting_position: jsonData["starting_position"] as String,
        moves: moves,
      );
    }
    throw "JsonData to Model wasn't transformed, \n"
      "Problem ->${{
        "room_id" : jsonData["room_id"] is String,
        "starting_position" : jsonData["starting_position"] is String,
        "moves" : (jsonData["moves"] is List || jsonData["moves"] == null)
      }}";
  }

  factory SudokuRoomModel.fromRTDB(DataSnapshot snapshot) {
    if(snapshot.child("room_id").value is String
        && snapshot.child("starting_position").value is String
        && (snapshot.child("moves").value is List || snapshot.child("moves").value == null)
    ){
      List<SudokuMove>? moves;
      if(snapshot.child("moves").value is List){
        moves = (snapshot.child("moves").value as List).map((e){
          if(e is! SudokuMove){
            try{
              // return SudokuMove.fromJson(e);
            }catch(e){
              print(e);
            }
          }
          return e;
        }).whereType<SudokuMove>().toList();
      }

      return SudokuRoomModel(
        room_id: snapshot.child("room_id").value as String,
        starting_position: snapshot.child("starting_position").value as String,
        moves: moves ?? [],
      );
    }
    throw "JsonData to Model wasn't transformed, \n"
        "Problem ->${{
      "roomId" : snapshot.child("room_id").value is String,
      "startingPosition" : snapshot.child("starting_position").value is String,
      "moves" : (snapshot.child("moves").value is List || snapshot.child("moves").value == null)
    }}";
  }

  Map<String, dynamic> toJson() => {
    "room_id": room_id,
    "starting_position": starting_position,
    "moves": moves,
  };

  @override
  String toString() {
    return toJson().toString();
  }
}