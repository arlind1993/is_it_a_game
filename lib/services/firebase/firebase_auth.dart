import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
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

  Future<FirebaseAuthUser> initialise() async {
    if (await InternetConnection().isConnected()) {
      _firebaseAuth = FirebaseAuth.instance;
    } else {
      _firebaseAuth = null;
    }
    InternetConnection().connectivityStream.listen((event){
      _firebaseAuth = InternetConnection().hasConnection(event) ? FirebaseAuth.instance : null;
    });
    return this;
  }

  Future<bool> updateEmail(String newEmail) async{
    if (await InternetConnection().isConnected()) {
      if(currentUser == null){
        return false;
      }
      try{
        currentUser!.updateEmail(newEmail);
        return true;
      }catch(e){
        log(e.toString());
        return false;
      }
    }else{
      return throw ({0: "There is no internet connection"});
    }
  }

  Future<bool> logOut() async {
    if (await InternetConnection().isConnected()) {
      if (_firebaseAuth == null) {
        return false;
      }
      try {
        await _firebaseAuth?.signOut();
        user = null;
        log("logOut notify Listener");
        return true;
      } catch (e) {
        log(e.toString());
        return false;
      }
    } else {
      return throw ({0: "There is no internet connection"});
    }
  }

  Future<bool> resetPassword(String email) async {
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

  Future<User?> signInAnonymously() async{
    if (await InternetConnection().isConnected()) {
      if (_firebaseAuth == null) {
        return null;
      }
      try {
        user = await _firebaseAuth?.signInAnonymously();
        return user?.user;
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
        user = await _firebaseAuth?.createUserWithEmailAndPassword(email: email, password: password);
        log(user.toString());
        return user?.user;
      } catch (e) {
        log(e.toString());
        return null;
      }
    } else {
      return throw ({0: "There is no internet connection"});
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    if (await InternetConnection().isConnected()) {
      if (_firebaseAuth == null) {
        return null;
      }
      try {
        user = await _firebaseAuth?.signInWithEmailAndPassword(email: email, password: password);
        return user?.user;
      } catch (e) {
        log(e.toString());
        return null;
      }
    } else {
      return throw ({0: "There is no internet connection"});
    }
  }

  Future<User?> signInWithGoogle() async {
    if (await InternetConnection().isConnected()) {
      if (_firebaseAuth == null) {
        return null;
      }
      try {
        user = await GoogleSignIn(
            scopes: [
              'email',
              'profile'
            ]
        ).signIn().then((value) {
          return value == null ? Future.value(null) : value.authentication;
        }).then((value) {
          return GoogleAuthProvider.credential(
            accessToken: value?.accessToken,
            idToken: value?.idToken,
          );
        }).then((value) {
          return _firebaseAuth!.signInWithCredential(value);
        });

        return user?.user;
      } catch (e) {
        log(e.toString());
        return null;
      }
    } else {
      return throw ({0: "There is no internet connection"});
    }
  }

  Future<User?> signInWithApple() async {
    if (await InternetConnection().isConnected()) {
      if (_firebaseAuth == null) {
        return null;
      }
      try {
        user = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName
          ],
        ).then((value) {
          return OAuthProvider('apple.com').credential(
            accessToken: value.authorizationCode,
            idToken: value.identityToken,
          );
        }).then((value) {
          return _firebaseAuth?.signInWithCredential(value);
        });

        return user?.user;
      } catch (e) {
        log(e.toString());
        return null;
      }
    } else {
      return throw ({0: "There is no internet connection"});
    }
  }

}