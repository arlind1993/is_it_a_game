import 'wire_tile.dart';

class WireGame{

  List<WireTile> tiles = [];

  WireGame({
    List<double>? rawImport,
    List<WireTile>? tileImport
  }){
    if(tileImport != null){
      tiles = tileImport;
    }
  }
}
