
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

  int get polarCords {
    switch(this){
      case TessellateType.triangle: return 3;
      case TessellateType.square: return 2;
      case TessellateType.hexagon: return 3;
      default: return 0;
    }
  }

  static TessellateType getFromValue(int value){
    switch(value){
      case 3: return TessellateType.triangle;
      case 4: return TessellateType.square;
      case 6: return TessellateType.hexagon;
      default: throw "Wierd value";
    }
  }
}