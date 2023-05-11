import 'types.dart';

class PolarTile implements Comparable{
  final TessellateType polygonTileForm;
  late List<int> coordinates;

  PolarTile({
    this.polygonTileForm = TessellateType.hexagon,
    List<int>? importCords,
  }){
    if(importCords != null && importCords.length == this.polygonTileForm.polarCords){
      this.coordinates = importCords;
    }else{
      this.coordinates = List.generate(this.polygonTileForm.polarCords, (index) => 0);
    }
  }

  setCords(List<int> importCords){
    if(importCords.length == this.polygonTileForm.polarCords){
      this.coordinates = importCords;
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
    if(other.polygonTileForm == this.polygonTileForm){
      throw "Objects comparing are not of same type -> $this and $other";
    }
    for(int i = 0; i < this.coordinates.length; i++){
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
    if(other.polygonTileForm == this.polygonTileForm){
      throw "Objects comparing are not of same type -> $this and $other";
    }

    List<int> newCords = [];

    for(int i = 0; i < this.coordinates.length; i++){
      newCords.add(this.coordinates[i] + other.coordinates[i]);
    }

    return PolarTile(importCords: newCords, polygonTileForm: polygonTileForm);
  }

  PolarTile operator -(Object other){
    if(other is! PolarTile){
      throw "Object to compare to is not the same type -> $this and $other";
    }
    if(other.polygonTileForm == this.polygonTileForm){
      throw "Objects comparing are not of same type -> $this and $other";
    }

    List<int> newCords = [];

    for(int i = 0; i < this.coordinates.length; i++){
      newCords.add(this.coordinates[i] - other.coordinates[i]);
    }

    return PolarTile(importCords: newCords, polygonTileForm: this.polygonTileForm);
  }

  @override
  int get hashCode => super.hashCode;
}