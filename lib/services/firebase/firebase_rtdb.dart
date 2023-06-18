import 'package:firebase_database/firebase_database.dart';
import 'internet_connection.dart';

enum DataChange{
  Insert,
  Update,
  Delete,
}


class FirebaseRTDB{
  static FirebaseRTDB _firebaseRtdb = FirebaseRTDB._private();
  factory FirebaseRTDB(){
    return _firebaseRtdb;
  }
  FirebaseRTDB._private();

  FirebaseDatabase? _firebaseDatabase;

  Future<FirebaseRTDB> initialise() async{
    await InternetConnection().isConnected().then((value) =>
      _firebaseDatabase = value ? FirebaseDatabase.instance : null
    );
    InternetConnection().connectivityStream.listen((event){
      _firebaseDatabase = InternetConnection().hasConnection(event) ? FirebaseDatabase.instance : null;
    });
    return this;
  }

  DatabaseReference? getReference([String? path]){
    return _firebaseDatabase?.ref(path);
  }

  Future<bool> dataExists({
    required String ref,
    bool Function(DataSnapshot dataSnapshot)? where,
  }) async{
    if(await InternetConnection().isConnected()) {
      if(getReference(ref) == null){
        return throw ({100: "reference is non existent"});
      }
      DatabaseReference dbf = getReference(ref)!;
      bool exists = false;
      for (DataSnapshot child in (await dbf.get()).children) {
        if(where == null || where(child)){
          exists = true;
          break;
        }
      }
      return exists;
    }else{
      return throw ({0: "There is no internet connection"});
    }
  }

  Future<String?> modifyData({
    required DataChange dataChange,
    required String ref,
    String? child,
    String? pushedChild,
    Map<String, dynamic>? data,
    bool updateIfAlreadyInserted = true
  }) async{
    if(await InternetConnection().isConnected()) {
      if (getReference(ref) == null) {
        return throw ({100: "reference is non existent"});
      }

      if (dataChange != DataChange.Insert) {
        if (getReference("$ref${child == null ? "" : "/$child"}") == null) {
          return throw ({100: "child reference is non existent"});
        }
      } else {
        if (child == null) {
          child = getReference(ref)!.push().key;
        }
        if (getReference("$ref${child == null ? "" : "/$child"}") != null && updateIfAlreadyInserted) {
          dataChange = DataChange.Update;
        }
      }

      DatabaseReference dbf = getReference("$ref${child == null ? "" : "/$child"}")!;
      switch (dataChange) {
        case DataChange.Insert:
          await dbf.set({
            if(pushedChild != null)
              pushedChild: child,
            ...?data
          });
          break;
        case DataChange.Update:
          await dbf.update({
            if(pushedChild != null)
              pushedChild: child,
            ...?data
          });
          break;
        case DataChange.Delete:
          await dbf.remove();
          break;
        default:
          return Future.error({4: "No data changed"});
      }
      return dbf.key;
    }else{
      return throw ({0: "There is no internet connection"});
    }
  }

  Future manipulateValue({
    required String ref,
    String? child,
    required String keyOfChange,
    required Function(dynamic value) action,
    bool onlyIfExists = true
  }) async{
    if(await InternetConnection().isConnected()) {
      if(getReference("$ref${child == null ? "" : "/$child"}") == null){
        return throw ({100: "child reference is non existent"});
      }
      DatabaseReference dbf = getReference("$ref${child == null ? "" : "/$child"}")!;
      dbf.update({
        keyOfChange: action((await dbf.child(keyOfChange).get()).value)
      });
    }else{
      return throw ({0: "There is no internet connection"});
    }
  }

  Stream<DatabaseEvent> gatherStreamData({
    required String ref,
    String? child,
  }){
    if(getReference("$ref${child == null ? "" : "/$child"}") == null){
      return throw ({100: "child reference is non existent"});
    }
    DatabaseReference dbf = getReference("$ref/${child == null ? "" : "/$child"}")!;
    return dbf.onValue;
  }

  Future<Iterable<Stream<DatabaseEvent>>> gatherStreamMultiData({
    required String ref,
    bool Function(DataSnapshot dataSnapshot)? where
  }) async{
    if(await InternetConnection().isConnected()) {
      if(getReference(ref) == null){
        return throw ({100: "reference is non existent"});
      }
      DatabaseReference dbf = getReference(ref)!;

      Future<Iterable<Stream<DatabaseEvent>>> result = dbf.get().then((value) {
        return value.children.where((element) {
          if(where == null){ return true; }
          return where(element);
        });
      }).then((value) {
        if (value.isEmpty) {
          return throw ({5: "There is no data with this id to get data from"});
        }
        return value;
      }).then((value) {
        return value.map((e) => dbf.child(e.key!).onValue);
      });

      return result;
    }else{
      return throw ({0: "There is no internet connection"});
    }
  }

  Future<DataSnapshot> gatherFutureData({
    required String ref,
    String? child,
  }) async{
    if(await InternetConnection().isConnected()){
      print("$ref${child == null ? "" : "/$child"}");
      if(getReference("$ref/${child == null ? "" : "/$child"}") == null){
        return throw ({100: "child reference is non existent"});
      }
      DatabaseReference dbf = getReference("$ref/${child == null ? "" : "/$child"}")!;
      return await dbf.get();
    }else{
      return throw ({0: "There is no internet connection"});
    }
  }

  Future<Iterable<Future<DataSnapshot>>> gatherFutureMultiData({
    required String ref,
    bool Function(DataSnapshot dataSnapshot)? where
  }) async{
    if(await InternetConnection().isConnected()){
      if(getReference(ref) == null){
        return throw ({100: "reference is non existent"});
      }
      DatabaseReference dbf = getReference(ref)!;
      Future<Iterable<Future<DataSnapshot>>> result = dbf.get().then((value){
        print(value.value);
        return value.children.where((element) {
          if(where == null){ return true; }
          return where(element);
        });
      }).then((value){
        // if(value.isEmpty){
        //   return throw ({5: "There is no data with this id to get data from"});
        // }
        return value;
      }).then((value) {
        return value.map((e)=>dbf.child(e.key!).get());
      });
      return result;
    }else{
      return throw ({0: "There is no internet connection"});
    }
  }
}

