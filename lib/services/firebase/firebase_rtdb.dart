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

  initialise() async{
    if(await InternetConnection().isConnected()) {
      _firebaseDatabase = FirebaseDatabase.instance;
    }else{
      _firebaseDatabase = null;
    }
    InternetConnection().connectivityStream.listen((event) async{
      if(await InternetConnection().isConnected(connectivityResult: event)){
        _firebaseDatabase = FirebaseDatabase.instance;
      }else{
        _firebaseDatabase = null;
      }
    });
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

  Future modifyData({
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
        if (getReference("$ref/$child") == null) {
          return throw ({100: "child reference is non existent"});
        }
      } else {
        if (child == null) {
          child = getReference(ref)!.push().key;
        }
        if (getReference("$ref/$child") != null && updateIfAlreadyInserted) {
          dataChange = DataChange.Update;
        }
      }

      DatabaseReference dbf = getReference("$ref/$child")!;
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
      return;
    }else{
      return throw ({0: "There is no internet connection"});
    }
  }

  Future manipulateValue({
    required String ref,
    required String child,
    required String keyOfChange,
    required Function(dynamic value) action,
    bool onlyIfExists = true
  }) async{
    if(await InternetConnection().isConnected()) {
      if(getReference("$ref/$child") == null){
        return throw ({100: "child reference is non existent"});
      }
      DatabaseReference dbf = getReference("$ref/$child")!;
      dbf.update({
        keyOfChange: action((await dbf.child(keyOfChange).get()).value)
      });
    }else{
      return throw ({0: "There is no internet connection"});
    }
  }

  Stream<DatabaseEvent> gatherStreamData({
    required String ref,
    required String child,
  }){
    if(getReference("$ref/$child") == null){
      return throw ({100: "child reference is non existent"});
    }
    DatabaseReference dbf = getReference("$ref/$child")!;
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
    required String child,
  }) async{
    if(await InternetConnection().isConnected()){
      print("$ref/$child");
      if(getReference("$ref/$child") == null){
        return throw ({100: "child reference is non existent"});
      }
      DatabaseReference dbf = getReference("$ref/$child")!;
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
        return value.children.where((element) {
          if(where == null){ return true; }
          return where(element);
        });
      }).then((value){
        if(value.isEmpty){
          return throw ({5: "There is no data with this id to get data from"});
        }
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

