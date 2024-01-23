import 'package:firebase_auth/firebase_auth.dart';
import 'package:game_template/services/get_it_helper.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class FirebaseAuthUser {
  factory FirebaseAuthUser.singleton() => FirebaseAuthUser._();
  FirebaseAuthUser._();

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  User? get currentUser => firebaseAuth.currentUser;

  Future<bool> updateEmail(String newEmail) async{
    if(!global.internet.value) throw ({0: "There is no internet connection"});
    if(currentUser == null) return false;
    return currentUser!.updateEmail(newEmail).then((value) => true);
  }

  Future<bool> logOut() async {
    if(!global.internet.value) throw ({0: "There is no internet connection"});
    if(currentUser == null) return false;
    return firebaseAuth.signOut().then((value) {
      return true;
    });
  }

  Future<bool> resetPassword(String email) async {
    if(!global.internet.value) throw ({0: "There is no internet connection"});
    if(currentUser == null) return false;
    return firebaseAuth.sendPasswordResetEmail(email: email).then((value) => true);
  }

  Future<User?> signInAnonymously() async{
    if(!global.internet.value) throw ({0: "There is no internet connection"});
    return firebaseAuth.signInAnonymously().then((value) => value.user);
  }

  Future<User?> registerEmail(String email, String password) async {
    if(!global.internet.value) throw ({0: "There is no internet connection"});
    return firebaseAuth.createUserWithEmailAndPassword(
      email: email, password: password
    ).then((value) => value.user);
  }

  Future<User?> signInWithEmail(String email, String password) async {
    if(!global.internet.value) throw ({0: "There is no internet connection"});
    return firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password
    ).then((value) => value.user);
  }

  Future<User?> signInWithGoogle() async {
    if(!global.internet.value) throw ({0: "There is no internet connection"});
    return GoogleSignIn(scopes: ['email', 'profile']).signIn().then((value) {
      return value == null ? Future.value(null) : value.authentication;
    }).then((value) {
      return GoogleAuthProvider.credential(
        accessToken: value?.accessToken,
        idToken: value?.idToken,
      );
    }).then((value) => firebaseAuth.signInWithCredential(value))
      .then((value) => value.user);
  }

  Future<User?> signInWithApple() async {
    if(!global.internet.value) throw ({0: "There is no internet connection"});
    return SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName
      ],
    ).then((value) {
      return OAuthProvider('apple.com').credential(
        accessToken: value.authorizationCode,
        idToken: value.identityToken,
      );
    }).then((value) => firebaseAuth.signInWithCredential(value))
      .then((value) => value.user);
  }


}