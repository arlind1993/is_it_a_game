import 'dart:math';
import 'dart:ui';
import 'polar_tile.dart';
import 'types.dart';

class PolarTileSize{
  final double zoom;
  final double edge;
  final TessellateType polygonTileForm;

  late final int edgeCount;
  late final int cords;

  double get _radianPerEdge => (2 * pi) / edgeCount;
  double get _radianInterior => (edgeCount - 2) * pi / edgeCount;

  double get _areaTile => (edgeCount * edge * edge) / (4 * tan( pi / edgeCount ));
  double get _radiusInscribed => edge / (2 * tan(pi/edgeCount)); //2 * _areaTile / (edgeCount * edge);
  double get _radiusCircumscribed => edge / (2 * cos(_radianInterior/2));


  PolarTileSize({
    this.zoom = 1,
    this.edge = 20,
    required this.polygonTileForm
  }) {
    cords = polygonTileForm.polarCords;
    edgeCount = polygonTileForm.value;
  }

  Offset getTileLocationCenter (PolarTile polarTile){
    if(polarTile.polygonTileForm != polygonTileForm ) {
      throw "not compatible";
    }

    if(polarTile.coordinates.length != polygonTileForm.polarCords){
      throw "cords not matching pt.c.l = ${polarTile.coordinates.length} and ptf.pc = ${polygonTileForm.polarCords}";
    }
    double x = 0;
    double y = 0;

    switch(polarTile.polygonTileForm) {
      case TessellateType.triangle:
        y = 2 * _radiusInscribed * (
           cos(0 * _radianPerEdge) * polarTile.coordinates[0]
           + cos(1 * _radianPerEdge) * polarTile.coordinates[1]
           + cos(2 * _radianPerEdge) * polarTile.coordinates[2]
        );
        x = 2 * _radiusInscribed * (
            sin(0 * _radianPerEdge) * polarTile.coordinates[0]
            + sin(1 * _radianPerEdge) * polarTile.coordinates[1]
            + sin(2 * _radianPerEdge) * polarTile.coordinates[2]
        );
        break;
      case TessellateType.square:
        y = 2 * _radiusInscribed * polarTile.coordinates[0];
        x = 2 * _radiusInscribed * polarTile.coordinates[1];
        break;
      case TessellateType.hexagon:
        y = 2 * _radiusInscribed * (
            cos(1 * _radianPerEdge) * polarTile.coordinates[1]
            + cos(2 * _radianPerEdge) * polarTile.coordinates[2]
        );
        x = 2 * _radiusInscribed * polarTile.coordinates[0];
        break;
      default:
        throw "Not a polygon type";
    }
    return Offset(x, y);
  }

  List<Offset> getTileVertices(PolarTile polarTile){
    Offset center = getTileLocationCenter(polarTile);
    List<Offset> points = [];

    switch(polarTile.polygonTileForm){
      case TessellateType.triangle:
        int res =0;
        for(int cord in polarTile.coordinates){
          res += cord;
        }
        if(res % 2 ==0){
          for(int i = 0; i < TessellateType.triangle.value; i++){
            points.add(Offset(
              sin((i - 0.5) * _radianPerEdge) * _radiusCircumscribed,
              cos((i - 0.5) * _radianPerEdge) * _radiusCircumscribed,
            ) + center);
          }
        }else{
          for(int i = 0; i < TessellateType.triangle.value; i++){
            points.add(Offset(
              sin((i - 0.5) * _radianPerEdge + pi) * _radiusCircumscribed,
              cos((i - 0.5) * _radianPerEdge + pi) * _radiusCircumscribed,
            ) + center);
          }
        }
        break;
      case TessellateType.square:
        for(int i = 0; i < TessellateType.square.value; i++){
          points.add(Offset(
            sin((i - 0.5) * _radianPerEdge) * _radiusCircumscribed,
            cos((i - 0.5) * _radianPerEdge) * _radiusCircumscribed,
          ) + center);
        }
        break;
      case TessellateType.hexagon:
        for(int i = 0; i < TessellateType.hexagon.value; i++){
          points.add(Offset(
            sin((i - 0.5) * _radianPerEdge) * _radiusCircumscribed,
            cos((i - 0.5) * _radianPerEdge) * _radiusCircumscribed,
          ) + center);
        }
        break;
      default:
        throw "Impossible";
    }

    return points;
  }
  String showExtraInfo(){
    return "RE: $_radianPerEdge\n"
    "RI: $_radianInterior\n"
    "A: $_areaTile\n"
    "RI: $_radiusInscribed\n"
    "RC: $_radiusCircumscribed\n"
    ;
  }
  
  PolarTile fromXYToPolar(Offset xyCords){
    double x = xyCords.dx;
    double y = xyCords.dx;
    PolarTile polarTile = PolarTile(polygonTileForm: polygonTileForm);
    switch(polygonTileForm){
      case TessellateType.triangle:
        break;
      case TessellateType.square:
        break;
      case TessellateType.hexagon:
        break;
      default: 
        throw "non compatible";
    }
    return polarTile;
  }
  
}

