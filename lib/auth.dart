import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signIn(String email, String password) async {
    FirebaseUser user =
        await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    return user.uid;
  }

  Future<String> signUp(String name, String email, String password) async {
    FirebaseUser user =
        await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

    UserUpdateInfo profileInfo = UserUpdateInfo();
    profileInfo.displayName = name;
    await user.updateProfile(profileInfo);

    return user.uid;
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }
}
