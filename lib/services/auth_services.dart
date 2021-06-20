import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<User?> signIn(String email, String password) async {
    var userCredential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return userCredential.user;
  }

  Future<User?> signUp(String email, String password) async {
    var userCredentials = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    return userCredentials.user;
  }

  Future signOut() async {
    await _auth.signOut();
  }

  Future resetPassword({required String email}) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
    }
  }
}
