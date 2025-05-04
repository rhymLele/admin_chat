import 'package:admin_user/model/message.dart';
import 'package:admin_user/model/report.dart';
import 'package:admin_user/model/user.dart';
import 'package:admin_user/model/user_account.dart';
import 'package:admin_user/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DatabaseService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
   final DatabaseReference _ref = FirebaseDatabase.instance.ref('users');
  //admin information
  Future<void> saveUserInforInFB(
      {required String name, required String email}) async {
    String uid = _auth.currentUser!.uid; //get current id

    String username = email.split('@')[0]; //exact username from email

    UserProfile user = UserProfile(
        uid: uid, name: name, email: email, username: username, bio: '');

    //convert to storing in fb
    final userMap = user.toMap();

    await _db.collection("Users").doc(uid).set(userMap);
  }
  Future<UserProfile?> getUserFromFB(String uid) async {
    try {
      DocumentSnapshot userDoc = await _db.collection("Users").doc(uid).get();
      if (!userDoc.exists) {
       debugPrint("User document does not exist for UID: $uid");
        return null;
      }
      return UserProfile.fromDocument(userDoc);
    } catch (e) {
   debugPrint('$e');
      return null;
    }
  }

  Future<UserProfile?> updateUserBioInFB(String bio) async {
    String uid = AuthService().getCurrentUid();
    try {
      await _db.collection("Users").doc(uid).update({'bio': bio});
    } catch (e) {
      debugPrint('$e');
    }
    return null;
  }
  Future<void> deleteAccountIn4(String uid) async {
    WriteBatch batch = _db.batch();
    DocumentReference userDoc = _db.collection("Users").doc(uid);
    batch.delete(userDoc);
    QuerySnapshot userPosts =
        await _db.collection("Posts").where('uid', isEqualTo: uid).get();
    for (var post in userPosts.docs) {
      batch.delete(post.reference);
    }
    QuerySnapshot userComments =
        await _db.collection("Comments").where('uid', isEqualTo: uid).get();
    for (var comment in userComments.docs) {
      batch.delete(comment.reference);
    }
    QuerySnapshot allPost = await _db.collection("Posts").get();
    for(QueryDocumentSnapshot post in allPost.docs){
        Map<String,dynamic> postData=post.data() as Map<String,dynamic>;
        var likedby=postData['likedBy'] as Map<String,dynamic>;
        if(likedby.containsKey(uid)){
          batch.update(post.reference, {
            'likedBy':FieldValue.arrayRemove([uid]),
            'likes':FieldValue.increment(-1),
          });
        }
    }
    await batch.commit();
  }

  
  //admin controll user account
Future<List<UserAccount>> getAllUserAccountsFromFb() async {
  try {
    final ref = FirebaseDatabase.instance.ref('users');
    final snapshot = await ref.get();

    if (!snapshot.exists) return [];

    final data = snapshot.value as Map<dynamic, dynamic>;

    final accounts = data.entries
        .where((entry) => (entry.value as Map)['phoneNumber'] != null)
        .map((entry) {
          final accountData = Map<String, dynamic>.from(entry.value);
          return UserAccount.fromDocument(accountData);
        })
        .toList();

    return accounts;
  } catch (e) {
    debugPrint("Error fetching all user accounts: $e");
    return [];
  }
}
Future<void> addUserAccount(UserAccount user) async {
  try {
    final ref = FirebaseDatabase.instance.ref('users');
    final newRef = ref.push(); // Tạo key mới
    await newRef.set(user.toMap());
  } catch (e) {
    debugPrint("Error adding user account: $e");
  }
}
Future<void> deleteUserByPhoneNumber(String phoneNumber) async {
  try {
    final ref = FirebaseDatabase.instance.ref('users');
    final snapshot = await ref.get();

    if (!snapshot.exists) return;

    final data = snapshot.value as Map<dynamic, dynamic>;

    for (var entry in data.entries) {
      final value = Map<String, dynamic>.from(entry.value);
      if (value['phoneNumber'] == phoneNumber) {
        await ref.child(entry.key).remove();
        break;
      }
    }
  } catch (e) {
    debugPrint("Error deleting user by phone: $e");
  }
}
 Future<void> updateUserPassword(UserAccount user, String newPassword) async {
    final snapshot = await _ref.get();
    if (!snapshot.exists) return;

    final data = snapshot.value as Map<dynamic, dynamic>;
    for (var entry in data.entries) {
      final value = Map<String, dynamic>.from(entry.value);
      if (value['phoneNumber'] == user.phoneNumber) {
        await _ref.child(entry.key).update({'password': newPassword.hashCode.toString()});
        break;
      }
    }
  }
Future<List<Report>> getReportFromFB() async {
     try {
      QuerySnapshot snapshot = await _db
          .collection("Reports")
          .orderBy("timestamp", descending: true)
          .get();
      return snapshot.docs.map((doc) => Report.fromDocument(doc)).toList();
    } catch (e) {
      print(e);
      return [];
    }
}
  Future<void> deleteReport(String reportId) async {
    try {
      await _db.collection("Reports").doc(reportId).delete();
    } catch (e) {
      print(e);
    }
  }
  Future<void> updateReportStatus(Report report, String status) async {
  await FirebaseFirestore.instance
      .collection('Reports')
      .doc(report.documentId)
      .update({'status': status});

  }
Future<List<Message>> getAllMessagesFromRTDB() async {
  try {
    final ref = FirebaseDatabase.instance.ref('chat');
    final snapshot = await ref.get();

    if (!snapshot.exists) return [];

    final Map<String, dynamic> rawData =
        Map<String, dynamic>.from(snapshot.value as Map);

    final messages = rawData.entries.map((entry) {
      final key = entry.key;
      final value = Map<String, dynamic>.from(entry.value as Map);
      return Message.fromRTDB(key, value);
    }).toList();

    messages.sort((a, b) => b.time.compareTo(a.time));
    debugPrint('Total messages fetched: ${messages.length}');

    return messages.take(10).toList();
  } catch (e) {
    debugPrint("Error fetching messages from RTDB: $e");
    return [];
  }
}




}