import 'package:flutter/material.dart';
import '../widgets/sudoku_play_board.dart';

class MainSudokuScreen extends StatefulWidget {
  const MainSudokuScreen({super.key});

  @override
  State<MainSudokuScreen> createState() => _MainSudokuScreenState();
}

class _MainSudokuScreenState extends State<MainSudokuScreen> {
  bool initialised = false;
  String? roomId;
  String? startingPosition;
  @override
  void initState() {
    setState(() {
      initialised = true;
    });
    
    try{
      // getIt<SudokuInternet>().handlePlayerColorConfirmation(, "arlind123").then((value){
      //   return getIt<SudokuInternet>().getRoomModel(value).then((roomModel) {
      //     if(roomModel!=null){
      //       setState(() {
      //         startingPosition = roomModel.starting_position;
      //         roomId = roomModel.room_id;
      //         initialised = true;
      //       });
      //     }
      //     return roomModel;
      //   });
      // });
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
        Expanded(
          child: Container(
            child: LayoutBuilder(
              builder: (context, constraint) {
                if(initialised){
                  print({"roomId": roomId,
                    "importedFenString": startingPosition,}
                    );
                  return SudokuPlayBoard(
                    key: Key("chess board"),
                    online: false,
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
          ),
        ),
      ],
    );
  }
}
