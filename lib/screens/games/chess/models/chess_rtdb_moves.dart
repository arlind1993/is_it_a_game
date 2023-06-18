import 'package:firebase_database/firebase_database.dart';

class ChessMovesModel{
  String algebraic_notation;
  String current_fen;

  ChessMovesModel({
    required this.algebraic_notation,
    required this.current_fen,
  });

  @override
  bool operator ==(Object other) {
    return other is ChessMovesModel
      && algebraic_notation == other.algebraic_notation
      && current_fen == other.current_fen;
  }

  factory ChessMovesModel.fromJson(Map<String, dynamic> jsonData) {
    if(jsonData["algebraic_notation"] is String
      && jsonData["current_fen"] is String){
      return ChessMovesModel(
        algebraic_notation: jsonData["algebraic_notation"],
        current_fen: jsonData["current_fen"]
      );
    }
    throw "JsonData to Model wasn't transformed, \n"
      "Problem ->${{
        "algebraic_notation": jsonData["algebraic_notation"] is String,
        "current_fen": jsonData["current_fen"] is String,
      }}";
  }

  factory ChessMovesModel.fromRTDB(DataSnapshot snapshot) {
    if(snapshot.child("algebraic_notation").value is String
      && snapshot.child("current_fen").value is String){
      return ChessMovesModel(
        algebraic_notation: snapshot.child("algebraic_notation").value as String,
        current_fen: snapshot.child("current_fen").value as String
      );
    }
    throw "Snapshot to Model wasn't transformed, \n"
      "Problem ->${{
        "algebraic_notation": snapshot.child("algebraic_notation").value is String,
        "current_fen": snapshot.child("current_fen").value is String,
      }}";
  }

  Map<String, dynamic> toJson() => {
    "algebraic_notation": algebraic_notation,
    "current_fen": current_fen,
  };

  @override
  String toString() {
    return toJson().toString();
  }
}