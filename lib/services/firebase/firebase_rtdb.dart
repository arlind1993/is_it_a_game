import 'package:firebase_database/firebase_database.dart';
import 'package:game_template/services/get_it_helper.dart';

enum DataChange{
  Insert,
  Update,
  Delete,
}


class FirebaseRTDB{
  factory FirebaseRTDB.singleton() =>  FirebaseRTDB._();
  FirebaseRTDB._();
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;

  DatabaseReference getReference([String? path]){
    return _firebaseDatabase.ref(path);
  }

  Future<bool> dataExists({
    required String ref,
    bool forSingleValue = false,
    bool Function(DataSnapshot dataSnapshot)? where,
  }) async{
    if(!global.internet.value) throw {0: "There is no internet connection"};
    return getReference(ref).get().then((value) {
      if(!value.exists || value.children.isEmpty) return false;
      if(forSingleValue){
       return where == null || where(value);
      }else{
        return value.children.every((element) => where == null || where(element));
      }
    });
  }

  Future<String?> modifyData({
    required DataChange dataChange,
    required String ref,
    String? child,
    String? pushedChild,
    Map<String, dynamic>? data,
    bool updateIfAlreadyInserted = true
  }) async{
    if(!global.internet.value) throw {0: "There is no internet connection"};

    if (dataChange == DataChange.Insert) {
      child ??= getReference(ref).push().key;
      if (updateIfAlreadyInserted) {
        dataChange = DataChange.Update;
      }
    }

    DatabaseReference dbf = getReference("$ref${child == null ? "" : "/$child"}");
    if(!(await dbf.get()).exists) throw {404: "Reference doesn't exist"};

    switch (dataChange) {
      case DataChange.Insert:return dbf.set({
        if(pushedChild != null)
          pushedChild: child,
        ...?data
      }).then((value) => dbf.key);
      case DataChange.Update: return dbf.update({
        if(pushedChild != null)
          pushedChild: child,
        ...?data
      }).then((value) => dbf.key);
      case DataChange.Delete: return dbf.remove().then((value) => dbf.key);
      default: throw ({0: "There is no internet connection"});
    }
  }

  Future manipulateValue({
    required String ref,
    String? child,
    required String keyOfChange,
    required Function(dynamic value) action,
    bool onlyIfExists = true
  }) async{
    if(!global.internet.value) throw ({0: "There is no internet connection"});
    DatabaseReference dbf = getReference("$ref${child == null ? "" : "/$child"}");
    if(!(await dbf.get()).exists) throw {404: "Reference doesn't exist"};
    return dbf.update({
      keyOfChange: action((await dbf.child(keyOfChange).get()).value)
    });
  }

  Stream<DatabaseEvent> gatherStreamData({
    required String ref,
    String? child,
  }){
    if(!global.internet.value) throw ({0: "There is no internet connection"});
    DatabaseReference dbf = getReference("$ref/${child == null ? "" : "/$child"}");
    return dbf.onValue;
  }

  Future<List<Stream<DatabaseEvent>>> gatherStreamMultiData({
    required String ref,
    bool Function(DataSnapshot dataSnapshot)? where
  }) async{
    if(!global.internet.value) throw ({0: "There is no internet connection"});

    DatabaseReference dbf = getReference(ref);
    return dbf.get().then((value) {
      if(!value.exists) throw {404: "Reference doesn't exist"};
      return value.children.where((element) {
        return where == null || where(element);
      });
    }).then((value) {
      return value.map((e) => dbf.child(e.key!).onValue).toList();
    });
  }

  Future<DataSnapshot> gatherFutureData({
    required String ref,
    String? child,
  }) async{
    if(!global.internet.value) throw ({0: "There is no internet connection"});
    DatabaseReference dbf = getReference("$ref/${child == null ? "" : "/$child"}");
    return dbf.get().then((value) {
      if(!value.exists) throw {404: "Reference doesn't exist"};
      return value;
    });
  }

  Future<List<Future<DataSnapshot>>> gatherFutureMultiData({
    required String ref,
    bool Function(DataSnapshot dataSnapshot)? where
  }) async{
    if(!global.internet.value) throw ({0: "There is no internet connection"});
    DatabaseReference dbf = getReference(ref);
    return dbf.get().then((value){
      if(!value.exists) throw {404: "Reference doesn't exist"};
      print(value.value);
      return value.children.where((element) {
        if(where == null){ return true; }
        return where(element);
      });
    }).then((value) {
      return value.map((e)=>dbf.child(e.key!).get()).toList();
    });
  }

  Future<List<DataSnapshot>> gatherFutureMultiDataComplete({
    required String ref,
    bool Function(DataSnapshot dataSnapshot)? where
  }) async{
    if(!global.internet.value) throw {0: "There is no internet connection"};
    DatabaseReference dbf = getReference(ref);
    return dbf.get().then((value){
      if(!value.exists) throw {404: "Reference doesn't exist"};
      print(value.value);
      return value.children.where((element) {
        if(where == null){ return true; }
        return where(element);
      });
    }).then((value) {
      return Future.wait(value.map((e)=>dbf.child(e.key!).get()));
    });
  }
}

