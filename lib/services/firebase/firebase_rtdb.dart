import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:game_template/services/firebase/firebase_auth.dart';
import 'package:game_template/services/get_it_helper.dart';

import '../helpers/internet_connection.dart';

enum DataChange{
  Insert,
  Update,
  Delete,
}

class FirebaseRTDB extends ChangeNotifier{
  FirebaseDatabase? _firebaseDatabase;

  initialise () async{
    if(await getIt<InternetConnection>().isConnected()) {
      _firebaseDatabase = FirebaseDatabase.instance;
    }else{
      _firebaseDatabase = null;
    }
    getIt<InternetConnection>().connectivityStream?.listen((event) async{
      if(await getIt<InternetConnection>().isConnected(connectivityResult: event)){
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
    required String keyOfId,
    required String id,
  }) async{
    if(await getIt<InternetConnection>().isConnected()) {
      DatabaseReference dbf = getReference(ref)!;
      DataSnapshot? userSnap;
      for (DataSnapshot child in (await dbf.get()).children) {
        if (child.child(keyOfId).value == id) {
          userSnap = child;
          break;
        }
      }
      return userSnap != null;
    }else{
      return throw ({0: "There is no internet connection"});
    }
  }

  Future modifyData({
    required String ref,
    required String keyOfId,
    String? id,
    required DataChange dataChange,
    bool isPushedId = false,
    Map<String, dynamic>? data
  }) async{
    if(await getIt<InternetConnection>().isConnected()) {
      if (getReference(ref) == null) {
        return null;
      }
      DatabaseReference dbf = getReference(ref)!;
      //log("${dbf.key}");
      DataSnapshot? userSnap;
      if (!isPushedId) {
        for (DataSnapshot child in (await dbf.get()).children) {
          if (child.child(keyOfId).value == id) {
            userSnap = child;
            break;
          }
        }
      }

      switch(dataChange) {
        case DataChange.Insert:
          if (userSnap == null) {
            if (isPushedId) {
              DatabaseReference dbnr = dbf.push();
              dbnr.set({
                keyOfId: dbnr.key,
                ...?data
              });
            } else {
              dbf.push().set({
                keyOfId: id,
                ...?data
              });
            }
          } else {
            return Future.error({1: "There is already a data insert as this id"});
          }
          break;
        case DataChange.Update:
          if (userSnap == null) {
            return Future.error({2: "There is no data with this id to update"});
          } else {
            if (userSnap.value.toString() !=
                {keyOfId: id, ...?data}.toString()) {
              dbf.child(userSnap.key!).update({
                ...?data
              });
            } else {
              log("new data and old data is the same no need for update");
            }
          }
          break;
        case DataChange.Delete:
          if (userSnap == null) {
            return Future.error({3: "There is no data with this id to delete"});
          } else {
            dbf.child(userSnap.key!).remove();
          }
          break;
        default:
          return Future.error({4: "No data changed"});
      }
    }else{
      return throw ({0: "There is no internet connection"});

    }
  }

  Future updateValue({
    required String ref,
    required String keyOfId,
    required String id,
    required String keyOfChange,
    required Function(dynamic value) action,
    bool onlyIfExists = true
  }) async{
    if(await getIt<InternetConnection>().isConnected()) {
      DatabaseReference dbf = getReference(ref)!;
      //log("${dbf.key}");
      DataSnapshot? userSnap;
      for (DataSnapshot child in (await dbf.get()).children) {
        if (child.child(keyOfId).value == id && (onlyIfExists
            ? (child.child(keyOfChange).exists && child.child(keyOfChange).value != null)
            : true)
        ) {
          userSnap = child;
          break;
        }
      }
      if (userSnap == null) {
        return Future.error({2: "There is no data with this id to update"});
      }
      dbf.child(userSnap.key!).update({
        keyOfChange: action(userSnap.child(keyOfChange).value).toString()
      });
    }else{
      return throw ({0: "There is no internet connection"});

    }
  }

  Future<Stream<DatabaseEvent>> gatherStreamData({
    required String ref,
    required String keyOfId,
    required String id,
  })async{
    if(await getIt<InternetConnection>().isConnected()){
      DatabaseReference dbf = getReference(ref)!;

      Future<Stream<DatabaseEvent>> temp=dbf.get().then((value){
        return value.children.where((element) {
          bool equal = element.child(keyOfId).value==id;
          return equal;
        });
      }).then((value){
        if(value.isEmpty){
          return throw ({5: "There is no data with this id to get data from"});
        }
        return value.first;
      }).then((value) {
        return dbf.child(value.key!).onValue;
      });

      return temp;
    }else{
      return throw ({0: "There is no internet connection"});
    }
  }

  Future<Iterable<Stream<DatabaseEvent>>> gatherStreamMultiData({
    required String ref,
    required bool Function(DataSnapshot dataSnapshot) where
  })async{
    if(_firebaseDatabase == null){
      return throw ({0: "There is no internet connection"});
    }
    if(await getIt<InternetConnection>().isConnected()) {
      DatabaseReference dbf = getReference(ref)!;

      Future<Iterable<Stream<DatabaseEvent>>> temp = dbf.get().then((value) {
        return value.children.where((element) => where(element));
      }).then((value) {
        if (value.isEmpty) {
          return throw ({5: "There is no data with this id to get data from"});
        }
        return value;
      }).then((value) {
        return value.map((e) => dbf.child(e.key!).onValue);
      });

      return temp;
    }else{
      return throw ({0: "There is no internet connection"});
    }
  }


  Future<Future<DataSnapshot>> gatherFutureData({
    required String ref,
    required String keyOfId,
    required String id,
  }) async{
    if(await getIt<InternetConnection>().isConnected()){
      DatabaseReference dbf = getReference(ref)!;

      Future<Future<DataSnapshot>> temp = dbf.get().then((value){
        return value.children.where((element) {
          bool equal = element.child(keyOfId).value==id;
          return equal;
        });
      }).then((value){
        if(value.isEmpty){
          return throw ({5: "There is no data with this id to get data from"});
        }
        return value.first;
      }).then((value) {
        return dbf.child(value.key!).get();
      });

      return temp;
    }else{
      return throw ({0: "There is no internet connection"});
    }
  }

  Future<Iterable<Future<DataSnapshot>>> gatherFutureMultiData({
    required String ref,
    bool Function(DataSnapshot dataSnapshot)? where
  }) async{
    if(await getIt<InternetConnection>().isConnected()){
      DatabaseReference dbf = getReference(ref)!;

      Future<Iterable<Future<DataSnapshot>>> temp = dbf.get().then((value){
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

      return temp;
    }else{
      return throw ({0: "There is no internet connection"});
    }
  }

  Future updateIsLoggedInInfo(bool loggedIn) async{
    try{
        await modifyData(
            ref: "users",
            keyOfId: "userId",
            id: getIt<FirebaseAuthUser>().user?.user?.uid,
            dataChange: DataChange.Update,
            data: {
              "loggedIn": loggedIn
            }
        );
    }catch(e){
      log("account may have been deleted or login details cant be updated");
    }
  }
}
