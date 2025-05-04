import 'package:admin_user/services/database/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //get instance of auth
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  //get current user id
  String getCurrentUid() => _auth.currentUser!.uid;

  //login => email; pw
  Future<UserCredential> loginWithEmailPassword(String email, password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<UserCredential> registerWithEmailPassword(String email, password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }
  Future<void> logOut() async{
    await _auth.signOut();
  }
  Future<void> deleteAccount() async{
    User? user=getCurrentUser();
    if(user!=null){
      await DatabaseService().deleteAccountIn4(user.uid);
      await user.delete();
    }
  }
}
