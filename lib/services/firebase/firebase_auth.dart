import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../get_it_helper.dart';
import '../helpers/internet_connection.dart';

class FirebaseAuthUser {

  FirebaseAuth? _firebaseAuth;
  UserCredential? user;

  Future initialise() async {
    if (await getIt<InternetConnection>().isConnected()) {
      _firebaseAuth = FirebaseAuth.instance;
    } else {
      _firebaseAuth = null;
    }

    getIt<InternetConnection>()..connectivityStream?.listen((event) async {
      if (await getIt<InternetConnection>().isConnected(connectivityResult: event)) {
        _firebaseAuth = FirebaseAuth.instance;
      } else {
        _firebaseAuth = null;
      }
    });
  }

  // Future<UserModel?> getActualUserAccount({String? givenUserId}) async {
  //   UserModel? userModel;
  //   if (user?.user?.uid != null || givenUserId != null) {
  //     try {
  //       DataSnapshot snapshot = await await FirebaseRTDB.instance
  //           .gatherFutureData(
  //           ref: "users",
  //           keyOfId: "userId",
  //           id: givenUserId ?? user!.user!.uid);
  //
  //       userModel = UserModel.fromRTDB(snapshot);
  //       //log("User: $userModel");
  //     } catch (e) {
  //       log("$e");
  //     }
  //   }
  //   return userModel;
  // }

  Future logOut() async {
    if (await getIt<InternetConnection>().isConnected()) {
      if (_firebaseAuth == null) {
        return null;
      }
      try {
        await _firebaseAuth!.signOut();
        user = null;

        log("logOut notify Listener");
        //notifyListeners();
      } catch (e) {
        log(e.toString());
        return null;
      }
    } else {
      return throw ({0: "There is no internet connection"});
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    if (await getIt<InternetConnection>().isConnected()) {
      if (_firebaseAuth == null) {
        return null;
      }
      try {
        UserCredential userCredential = await _firebaseAuth!
            .signInWithEmailAndPassword(email: email, password: password);
        user = userCredential;
        //log("$user");
        //notifyListeners();
        return userCredential.user;
      } catch (e) {
        log(e.toString());
        return null;
      }
    } else {
      return throw ({0: "There is no internet connection"});
    }
  }

  Future<User?> registerEmail(String email, String password) async {
    if (await getIt<InternetConnection>().isConnected()) {
      if (_firebaseAuth == null) {
        return null;
      }
      try {
        UserCredential userCredential = await _firebaseAuth!
            .createUserWithEmailAndPassword(email: email, password: password);
        user = userCredential;
        log(user.toString());
        //notifyListeners();
        return userCredential.user;
      } catch (e) {
        log(e.toString());
        return null;
      }
    } else {
      return throw ({0: "There is no internet connection"});
    }
  }

  Future<User?> signInWithGoogle() async {
    if (await getIt<InternetConnection>().isConnected()) {
      if (_firebaseAuth == null) {
        return null;
      }
      try {
        log("Here1");
        GoogleSignIn s = GoogleSignIn(
            scopes: [
              'email',
              'profile'
            ]
        );
        GoogleSignInAccount? googleUser;
        googleUser = await s.signOut();
        googleUser = await s.signIn();

        if (googleUser == null) {
          return null;
        }
        GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        OAuthCredential googleCredential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential =
        await _firebaseAuth!.signInWithCredential(googleCredential);
        user = userCredential;
        //log("$user");
        //notifyListeners();
        return userCredential.user;
      } catch (e) {
        log(e.toString());
        return null;
      }
    } else {
      return throw ({0: "There is no internet connection"});
    }
  }

  Future<User?> signInWithApple() async {
    if (await getIt<InternetConnection>().isConnected()) {
      if (_firebaseAuth == null) {
        return null;
      }
      try {
        AuthorizationCredentialAppleID appleCredential =
        await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName
          ],
        );

        OAuthProvider oAuthProvider = OAuthProvider('apple.com');
        OAuthCredential googleCredential = oAuthProvider.credential(
          accessToken: appleCredential.authorizationCode,
          idToken: appleCredential.identityToken,
        );
        UserCredential userCredential =
        await _firebaseAuth!.signInWithCredential(googleCredential);
        user = userCredential;
        //log("$user");
        //notifyListeners();
        return userCredential.user;
      } catch (e) {
        log(e.toString());
        return null;
      }
    } else {
      return throw ({0: "There is no internet connection"});
    }
  }

  Future resetPassword(String email) async {
    if (await getIt<InternetConnection>().isConnected()) {
      if (_firebaseAuth == null) {
        return false;
      }
      try {
        _firebaseAuth!.sendPasswordResetEmail(email: email);
        return true;
      } catch (e) {
        log(e.toString());
        return false;
      }
    } else {
      return throw ({0: "There is no internet connection"});
    }
  }

  deleteUser({required String userId}) async{
    if (await getIt<InternetConnection>().isConnected()) {
      if (_firebaseAuth == null) {
        return false;
      }
      try {
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