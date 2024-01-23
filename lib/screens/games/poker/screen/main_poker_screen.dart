
import 'package:flutter/material.dart';
import 'package:game_template/screens/cards/card_model.dart';
import '../../../cards/deck_model.dart';
import '../widgets/poker_play.dart';
class MainPokerScreen extends StatefulWidget {
  const MainPokerScreen({super.key});

  @override
  State<MainPokerScreen> createState() => _MainPokerScreenState();
}

class _MainPokerScreenState extends State<MainPokerScreen> {
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
          return PokerPlay(
            key: Key("poker board"),
            deck: DeckModel(cardType: CardType.poker),
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
