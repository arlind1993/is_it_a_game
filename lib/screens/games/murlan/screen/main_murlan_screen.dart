
import 'package:flutter/material.dart';
import 'package:game_template/screens/cards/card_model.dart';
import '../../../cards/deck_model.dart';
import '../widgets/murlan_play.dart';
class MainMurlanScreen extends StatefulWidget {
  const MainMurlanScreen({super.key});

  @override
  State<MainMurlanScreen> createState() => _MainMurlanScreenState();
}

class _MainMurlanScreenState extends State<MainMurlanScreen> {
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
            deck: DeckModel(cardType: CardType.murlan),
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
