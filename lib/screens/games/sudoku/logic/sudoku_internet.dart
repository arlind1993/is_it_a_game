import 'package:game_template/services/firebase/firebase_rtdb.dart';
import '../../../../services/get_it_helper.dart';
import '../models/sudoku_rtdb_room.dart';

class SudokuInternet{
  static SudokuInternet _chessInternet = SudokuInternet._();
  factory SudokuInternet(){
    return _chessInternet;
  }
  SudokuInternet._();

  Future<String?> createNewSudokuRoomId() async{
    try{
      return getIt<FirebaseRTDB>().modifyData(
        dataChange: DataChange.Insert,
        ref: "chess/rooms",
        pushedChild: "room_id",
        updateIfAlreadyInserted: true,
        data: {
          "starting_position": "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
        }
      );
    }catch(e){
      print(e);
      return null;
    }
  }

  Future<String> handlePlayerColorConfirmation(bool playerIsWhite, String playerUserId) async{
    print("handlePlayerColorConfirmation($playerIsWhite, $playerUserId)");
    return getIt<FirebaseRTDB>().gatherFutureMultiData(
      ref: "chess/rooms",
      where: (snapshot) {
        if(playerIsWhite){
          return snapshot.child("player_white_id").value == null;
        }else{
          return snapshot.child("player_black_id").value == null;
        }
      },
    ).then((dataPool) {
      if(dataPool.isEmpty){
        return createNewSudokuRoomId().then((value) => value!);
      }else{
       return dataPool.first.then((value) => value.child("room_id").value as String);
      }
    }).then((roomId) {
      return getIt<FirebaseRTDB>().modifyData(
        dataChange: DataChange.Update,
        ref: "chess/rooms",
        child: roomId,
        data: {
          if(playerIsWhite) "player_white_id": playerUserId
          else "player_black_id": playerUserId,
        }
    ).then((value) => roomId);
    });
  }

  Future<SudokuRoomModel?> getRoomModel(String roomId) async{
    try{
      return getIt<FirebaseRTDB>().gatherFutureData(
          ref: "chess/rooms",
          child: roomId
      ).then((value){
        return SudokuRoomModel.fromRTDB(value);
      });
    }catch(e){
      print(e);
      return null;
    }
  }

}