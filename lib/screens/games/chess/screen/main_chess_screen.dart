import 'dart:math';

import 'package:flutter/material.dart';
import 'package:game_template/screens/games/chess/logic/chess_internet.dart';
import '../../../../services/get_it_helper.dart';
import '../widgets/chess_play_board.dart';

class MainChessScreen extends StatefulWidget {
  const MainChessScreen({super.key});

  @override
  State<MainChessScreen> createState() => _MainChessScreenState();
}

class _MainChessScreenState extends State<MainChessScreen> {
  bool initialised = false;
  late String roomId;
  late String startingPosition;
  late bool youAreWhite;
  @override
  void initState() {
    setState(() {
      initialised = false;
    });
    try{
      youAreWhite = Random().nextBool();
      getIt<ChessInternet>().handlePlayerColorConfirmation(youAreWhite, "arlind123").then((value){
        return getIt<ChessInternet>().getRoomModel(value).then((roomModel) {
          if(roomModel!=null){
            setState(() {
              startingPosition = roomModel.starting_position;
              roomId = roomModel.room_id;
              initialised = true;
            });
          }
          return roomModel;
        });
      });
    }catch(e){
      print(e);
    }
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if(mounted) super.setState(fn);
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 30,),
        Builder(
          builder: (context) {
            if(initialised){
              print({"roomId": roomId,
                "importedFenString": startingPosition,
                "youAreWhite": youAreWhite,});
              return ChessPlayBoard(
                key: Key("chess board"),
                roomId: roomId,
                importedFenString: startingPosition,
                youAreWhite: youAreWhite,
                online: true,
              );
            }else{
              return LayoutBuilder(
                builder: (context, constraint) => Container(
                  width: constraint.maxWidth,
                  height: constraint.maxWidth,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              );
            }
          }
        ),
        Expanded(child: Container()),
      ],
    );
  }
}
