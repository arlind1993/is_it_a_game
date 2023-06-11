import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'internet_connection.dart';

class FirebaseAuthUser {
  static FirebaseAuthUser _firebaseAuthUser = FirebaseAuthUser._();
  factory FirebaseAuthUser(){
    return _firebaseAuthUser;
  }
  FirebaseAuth? _firebaseAuth;
  UserCredential? user;

  User? get currentUser => _firebaseAuth?.currentUser;

  FirebaseAuthUser._();

  Future initialise() async {
    if (await InternetConnection().isConnected()) {
      _firebaseAuth = FirebaseAuth.instance;
    } else {
      _firebaseAuth = null;
    }
    InternetConnection().connectivityStream.listen((event) async {
      if (await InternetConnection().isConnected(connectivityResult: event)) {
        _firebaseAuth = FirebaseAuth.instance;
      } else {
        _firebaseAuth = null;
      }
    });
  }

  Future<bool> updateEmail(String newEmail) async{
    if(currentUser != null && newEmail !=null){
      try{
        currentUser?.updateEmail(newEmail);
        return true;
      }catch(e){
        print(e);
        return false;
      }
    }else{
      return false;
    }
  }

  Future logOut() async {
    if (await InternetConnection().isConnected()) {
      if (_firebaseAuth == null) {
        return null;
      }
      try {
        await _firebaseAuth?.signOut();
        user = null;

        log("logOut notify Listener");
      } catch (e) {
        log(e.toString());
        return null;
      }
    } else {
      return throw ({0: "There is no internet connection"});
    }
  }

  Future<User?> signInAnonymously() async{
    UserCredential? userCredential = await _firebaseAuth?.signInAnonymously();
    user = userCredential;
    return userCredential?.user;
  }

  Future<User?> signInWithEmail(String email, String password) async {
    if (await InternetConnection().isConnected()) {
      if (_firebaseAuth == null) {
        return null;
      }
      try {
        UserCredential? userCredential = await _firebaseAuth?.signInWithEmailAndPassword(email: email, password: password);
        user = userCredential;
        //log("$user");
        return userCredential?.user;
      } catch (e) {
        log(e.toString());
        return null;
      }
    } else {
      return throw ({0: "There is no internet connection"});
    }
  }

  Future<User?> registerEmail(String email, String password) async {
    if (await InternetConnection().isConnected()) {
      if (_firebaseAuth == null) {
        return null;
      }
      try {
        UserCredential? userCredential = await _firebaseAuth?.createUserWithEmailAndPassword(email: email, password: password);
        user = userCredential;
        log(user.toString());
        return userCredential?.user;
      } catch (e) {
        log(e.toString());
        return null;
      }
    } else {
      return throw ({0: "There is no internet connection"});
    }
  }

  Future resetPassword(String email) async {
    if (await InternetConnection().isConnected()) {
      if (_firebaseAuth == null) {
        return false;
      }
      try {
        _firebaseAuth?.sendPasswordResetEmail(email: email);
        return true;
      } catch (e) {
        log(e.toString());
        return false;
      }
    } else {
      return throw ({0: "There is no internet connection"});
    }
  }
}