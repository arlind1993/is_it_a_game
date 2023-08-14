import 'package:flutter_svg/flutter_svg.dart';

class CardConstants{
  final SvgPicture cardBack = SvgPicture.asset("assets/images/cards/back");
  SvgPicture cardImageImporter(String relativeCardName){
    return SvgPicture.asset("assets/images/cards/$relativeCardName");
  }

}