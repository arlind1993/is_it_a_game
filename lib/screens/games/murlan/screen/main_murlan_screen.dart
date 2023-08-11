import 'dart:math';

import 'package:flutter/material.dart';
import 'package:game_template/screens/games/chess/logic/chess_internet.dart';
import '../../../../services/get_it_helper.dart';
import '../../../cards/deck_model.dart';
import '../widgets/murlan_play.dart';
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
      initialised = true;
    });
    try{
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
    return Builder(
      builder: (context) {
        if(initialised){
          return MurlanPlay(
            key: Key("chess board"),
            deck: DeckModel(),
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
    );
  }
}
