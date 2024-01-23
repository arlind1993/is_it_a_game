import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../widgets/text_widget.dart';


enum CardType{
  murlan,
  poker,
  hearts
}

class CardModel extends StatelessWidget {
  static const double SIZE_FACTOR = 3.5;
  static const Size CARD_SIZE = const Size(25 * SIZE_FACTOR, 35 * SIZE_FACTOR);
  static const Map<int, Map<String, dynamic>> moreInfoNumbers = {
    1:  {"display": "A" , "murlanValue": 12},
    2:  {"display": "2" , "murlanValue": 13},
    3:  {"display": "3" , "murlanValue": 1 },
    4:  {"display": "4" , "murlanValue": 2 },
    5:  {"display": "5" , "murlanValue": 3 },
    6:  {"display": "6" , "murlanValue": 4 },
    7:  {"display": "7" , "murlanValue": 5 },
    8:  {"display": "8" , "murlanValue": 6 },
    9:  {"display": "9" , "murlanValue": 7 },
    10: {"display": "10", "murlanValue": 8 },
    11: {"display": "J" , "murlanValue": 9 },
    12: {"display": "Q" , "murlanValue": 10},
    13: {"display": "K" , "murlanValue": 11},
    14: {"display": "BJ", "murlanValue": 14},
    15: {"display": "RJ", "murlanValue": 15},
  };
  static const Map<int, Map<String, dynamic>> moreInfoSuits = {
    0: {"display": " ", "name": ""        },
    1: {"display": "♠", "name": "spades"  },
    2: {"display": "♦", "name": "diamonds"},
    3: {"display": "♣", "name": "clubs"   },
    4: {"display": "♥", "name": "hearts"  },
  };

  final int number;
  final int suit;
  final int actualValue;
  final CardType cardType;
  bool isCardSelected;

  CardModel({
    required this.number,
    required this.suit,
    required this.cardType,
    this.isCardSelected = false,
  }): actualValue = moreInfoNumbers[number]!["${cardType.name}Value"]!;

  SvgPicture get cardBack => SvgPicture.asset("assets/images/cards/back.svg");
  SvgPicture get cardImageImporter => SvgPicture.asset(
    "assets/images/cards/$numberDisplay${suit == 0? "":"_"}$suitName.svg"
  );
  String get  numberDisplay => moreInfoNumbers[number]!["display"]!;
  String get suitDisplay => moreInfoSuits[suit]!["display"]!;
  String get suitName => moreInfoSuits[suit]!["name"]!;

  void toggleCardSelected(){
    isCardSelected = !isCardSelected;
  }


  @override
  bool operator ==(Object other) {
    return other is CardModel && number == other.number && suit == other.suit;
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return moreInfoNumbers[number]!["display"]! + moreInfoSuits[suit]!["display"]!;
  }

  @override
  Widget build(BuildContext context) {
    final int showChildPos = 2;
    return IndexedStack(
      index: showChildPos,
      children: [
        Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(2, (indexR) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(2, (index) => RotatedBox(
                  quarterTurns: indexR == 0 ? 0 : 2,
                  child: TextWidget(
                      text: "$numberDisplay\n$suitDisplay"
                  ),
                ))
            )),
          ),
        ),
        cardBack,
        cardImageImporter
      ],
    );
  }
}
