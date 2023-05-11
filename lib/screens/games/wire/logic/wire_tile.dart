import 'polar_tile.dart';
import 'polar_tile_draw.dart';
import 'types.dart';

class WireTile{
  final TileType tileType;
  late final TessellateType polygonTileForm;
  late final PolarTileSize tileSize;
  late final PolarTile polarTile;
  late List<bool> connections;
  late List<WireTile?> neighbours;

  WireTile({
    TessellateType? polygonTileForm,
    this.tileType = TileType.none,
    List<bool>? connectionsImport,
    List<WireTile?>? neighboursImport,
    List<int>? importPolarCords,
  }){
    this.polygonTileForm = polygonTileForm ?? TessellateType.hexagon;
    this.tileSize = PolarTileSize(polygonTileForm: this.polygonTileForm);
    this.polarTile = PolarTile(polygonTileForm: this.polygonTileForm, importCords: importPolarCords);
    if(connectionsImport != null && connectionsImport.length == this.polygonTileForm.value){
      this.connections = connectionsImport;
    }else{
      this.connections = List.generate(this.polygonTileForm.polarCords, (index) => false);
    }
    if(neighboursImport != null && neighboursImport.length == this.polygonTileForm.value){
      this.neighbours = neighboursImport;
    }else{
      this.neighbours = List.generate(this.polygonTileForm.polarCords, (index) => null);
    }
  }

  setConnections(List<bool> connectionsImport){
    if(connectionsImport.length == this.polygonTileForm.value){
      this.connections = connectionsImport;
    }else{
      throw "Not the right amount of connections";
    }
  }
  setNeighbours(List<WireTile?> neighboursImport){
    if(neighboursImport.length == this.polygonTileForm.value){
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