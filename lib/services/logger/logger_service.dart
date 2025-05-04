import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoggerService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> logAdminAction(String action, Map<String, dynamic> details) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('admin_logs').add({
      'uid': user.uid,
      'action': action,
      'details': details,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getAdminLogs() {
    return _firestore.collection('admin_logs')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
