import 'dart:collection';
import 'package:logging/logging.dart';

import 'chess_constants.dart';

class ChessLocation extends LinkedListEntry<ChessLocation> implements Comparable{
  late int rank;
  late int file;
  bool get inside => (rank >= 1 && rank <= ChessConstants().CHESS_SIZE_SQUARE) && (file >= 1 && file <= ChessConstants().CHESS_SIZE_SQUARE);
  String get nameConvention => inside ? fileName + rankName : "out";
  String get fileName => String.fromCharCode(96 + file);
  String get rankName => rank.toString();
  Logger _logger = Logger("Chess piece logic");

  ChessLocation({
    required this.rank,
    required this.file,
  });

  ChessLocation.clone(ChessLocation chessLocation) :
    this.rank = chessLocation.rank,
    this.file = chessLocation.file;


  ChessLocation.fromPieceFen(String notation){
    String fileIntString = "";
    String rankIntString = "";
    for(int i = 0;  i < notation.length; i++){
      int character = notation.codeUnitAt(i);
      if(character >= 48 && character < 58){
        rankIntString += "${character - 48}";
      }else if(character >= 97 && character < 123){
        fileIntString += "${character - 96}";
      }
    }
    file = int.parse(fileIntString);
    rank = int.parse(rankIntString);
  }

  @override
  int compareTo(other) {
    if(other is ChessLocation) {
      return ((ChessConstants().CHESS_SIZE_SQUARE - rank) * ChessConstants().CHESS_SIZE_SQUARE + (file))-
          ((ChessConstants().CHESS_SIZE_SQUARE - other.rank) * ChessConstants().CHESS_SIZE_SQUARE + (other.file));
    }
    throw "Non Location type error";
  }

  bool operator == (Object other) => this.compareTo(other) == 0;
  bool operator >  (Object other) => this.compareTo(other) >  0;
  bool operator >= (Object other) => this.compareTo(other) >= 0;
  bool operator <  (Object other) => this.compareTo(other) <  0;
  bool operator <= (Object other) => this.compareTo(other) <= 0;

  ChessLocation operator +(Object other){
    if(other is ChessLocation){
      return ChessLocation(
        rank: rank + other.rank,
        file: file + other.file
      );
    }
    throw "Non Location type error";
  }

  ChessLocation operator -(Object other){
    if(other is ChessLocation){
      return ChessLocation(
          rank: rank - other.rank,
          file: file - other.file
      );
    }
    throw "Non Location type error";
  }

  @override
  int get hashCode => rank * ChessConstants().CHESS_SIZE_SQUARE + file;

  @override
  String toString() {
    return nameConvention;
  }
}