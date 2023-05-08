import 'dart:math';
import 'dart:ui';


////    Shapes                Axis

////       4               3<\    />2
////     =====                \  /
////  5 /     \ 3              \/
////  6 \     / 2        4<====/\====>1
////     =====                /  \
////       1               5</    \>6

////       -                2<\  /
////    3 / \ 2                \/
////     /   \             ==========>1
////    =======                /\
////       1                3</  \

////       3                    ^ 2
////    =======                 |
////  4 |     | 2         3<=========>1
////    |     |                 |
////    =======               4 v
////       1


enum TileType{
  source,
  teleport,
  wire,
  none,
}

enum TessellateType{
  triangle,
  square,
  hexagon,
}

extension TessellationType on TessellateType{
  int get value {
    switch(this){
      case TessellateType.triangle: return 3;
      case TessellateType.square: return 4;
      case TessellateType.hexagon: return 6;
      default: return 0;
    }
  }
}

class WireTile{
  late int polygonTileForm;
  late PolarTileSize tileSize;
  late PolarTile polarTile;
  late List<bool> connections;
  late List<WireTile?> neighbours;
  TileType tileType;

  WireTile({
    int? polygonTileForm,
    this.tileType = TileType.none,
    List<bool>? connectionsImport,
    List<WireTile?>? neighboursImport,
  }){
    this.polygonTileForm = polygonTileForm ?? TessellateType.hexagon.value;
    this.tileSize = PolarTileSize.defaultTileSize(this.polygonTileForm);
    this.polarTile = PolarTile(pi2Fractional: this.polygonTileForm);
    if(connectionsImport != null && connectionsImport.length == this.polygonTileForm){
      this.connections = connectionsImport;
    }else{
      this.connections = List.generate(this.polygonTileForm, (index) => false);
    }
    if(neighboursImport != null && neighboursImport.length == this.polygonTileForm){
      this.neighbours = neighboursImport;
    }else{
      this.neighbours = List.generate(this.polygonTileForm, (index) => null);
    }
  }

  setConnections(List<bool> connectionsImport){
    if(connectionsImport.length == this.polygonTileForm){
      this.connections = connectionsImport;
    }else{
      throw "Not the right amount of connections";
    }
  }
  setNeighbours(List<WireTile?> neighboursImport){
    if(neighboursImport.length == this.polygonTileForm){
      this.neighbours = neighboursImport;
    }else{
      throw "Not the right amount of neighbours";
    }
  }

  spin(){
    bool temp = connections.first;
    connections.removeAt(0);
    connections.add(temp);
  }

}

class PolarTileSize{
  final double zoom;
  final double edge;
  final int edgeCount;

  double get _radian => 2 * pi * (1 / edgeCount.toDouble());
  //double get _areaTile => (edgeCount * edge * edge) / (4 * tan(pi/edgeCount));
  double get _radiusInscribed =>  edge / (2 * tan(pi/edgeCount)); //2 * _areaTile / (edgeCount * edge);


  const PolarTileSize.defaultTileSize(this.edgeCount):
    this.edge = 40,
    this.zoom = 1;

  const PolarTileSize({
    required this.zoom,
    required this.edge,
    required this.edgeCount
  });

  Offset getTileLocationCenter (PolarTile polarTile){
    if(polarTile.pi2Fractional != edgeCount) {
      throw "not compatible";
    }
    //TODO: Location Add;
    return Offset(0, 0);
  }

}


class WireGame{
  List<WireTile> tiles = [];

}


class PolarTile implements Comparable{

  late int pi2Fractional;
  late List<int> coordinates;



  PolarTile({
    int? pi2Fractional,
    List<int>? importCords,
  }){
    this.pi2Fractional = pi2Fractional ?? TessellateType.hexagon.value;
    if(importCords != null && importCords.length == this.pi2Fractional){
      if(importCords.length % 2 == 0){
        bool eqOp = true;
        for(int i = 0; i < importCords.length / 2; i++){
          if(importCords[i] != -importCords[i+importCords.length~/2]){
            eqOp = false;
            break;
          }
        }
        if(eqOp){
          this.coordinates = importCords;
        }else{
          this.coordinates = List.generate(this.pi2Fractional, (index) => 0);
        }
      }else{
        this.coordinates = importCords;
      }
    }else{
      this.coordinates = List.generate(this.pi2Fractional, (index) => 0);
    }
  }

  setCords(List<int> importCords){
    if(importCords.length == this.pi2Fractional){
      if(importCords.length % 2 == 0){
        bool eqOp = true;
        for(int i = 0; i < importCords.length / 2; i++){
          if(importCords[i] != -importCords[i+importCords.length~/2]){
            eqOp = false;
            break;
          }
        }
        if(eqOp){
          this.coordinates = importCords;
        }else{
          throw "Not equal opposites when cords.length is not divisible by 2";
        }
      }else{
        this.coordinates = importCords;
      }
    }else{
      throw "length of array of axis is not equal to polar type";
    }
  }

  @override
  bool operator == (Object other) => compareTo(other) == 0;
  bool operator <  (Object other) => compareTo(other) <  0;
  bool operator <= (Object other) => compareTo(other) <= 0;
  bool operator >  (Object other) => compareTo(other) >  0;
  bool operator >= (Object other) => compareTo(other) >= 0;

  @override
  int compareTo(other) {
    if(other is! PolarTile){
      throw "Object to compare to is not the same type -> $this and $other";
    }
    if(other.pi2Fractional == this.pi2Fractional){
      throw "Objects comparing are not of same type -> $this and $other";
    }
    for(int i = 0; i < this.pi2Fractional; i++){
      if(this.coordinates[i] != other.coordinates[i]){
        return this.coordinates[i] - other.coordinates[i];
      }
    }
    return 0;
  }

  PolarTile operator +(Object other){
    if(other is! PolarTile){
      throw "Object to compare to is not the same type -> $this and $other";
    }
    if(other.pi2Fractional == this.pi2Fractional){
      throw "Objects comparing are not of same type -> $this and $other";
    }

    List<int> newCords = [];

    for(int i = 0; i < this.pi2Fractional; i++){
      newCords.add(this.coordinates[i] + other.coordinates[i]);
    }

    return PolarTile(importCords: newCords, pi2Fractional: this.pi2Fractional);
  }

  PolarTile operator -(Object other){
    if(other is! PolarTile){
      throw "Object to compare to is not the same type -> $this and $other";
    }
    if(other.pi2Fractional == this.pi2Fractional){
      throw "Objects comparing are not of same type -> $this and $other";
    }

    List<int> newCords = [];

    for(int i = 0; i < this.pi2Fractional; i++){
      newCords.add(this.coordinates[i] - other.coordinates[i]);
    }

    return PolarTile(importCords: newCords, pi2Fractional: this.pi2Fractional);
  }

  @override
  int get hashCode => super.hashCode;
}