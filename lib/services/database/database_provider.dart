/*
this provider is to separate the firestore data handling and the UI of app
the database service class handles data to and from firebase
the database provider processes the data to display in app
 */
import 'package:admin_user/model/message.dart';
import 'package:admin_user/model/report.dart';
import 'package:admin_user/model/user.dart';
import 'package:admin_user/model/user_account.dart';
import 'package:admin_user/services/auth/auth_service.dart';
import 'package:admin_user/services/database/database_service.dart';
import 'package:flutter/cupertino.dart';

class DatabaseProvider extends ChangeNotifier {
  final auth = AuthService();
  final db = DatabaseService();

  Future<UserProfile?> userProfile(String uid) => db.getUserFromFB(uid);

  Future<void> updateBio(String bio) => db.updateUserBioInFB(bio);

  //getAllUserAccount
  List<UserAccount> allAccounts = [];
  List<Report> allReports = [];
  List<Message> allMessages=[];

Future<void> fetchAllUserAccounts() async {
  allAccounts = await db.getAllUserAccountsFromFb();
  notifyListeners();
}
Future<void> addUserAccount(UserAccount user) async {
  await db.addUserAccount(user);
  await fetchAllUserAccounts();
  notifyListeners();
}

Future<void> deleteUserAccount(UserAccount user) async {
  await db.deleteUserByPhoneNumber(user.phoneNumber);
  await fetchAllUserAccounts();
  notifyListeners();
}
Future<void> updateUserPassword(UserAccount user,String password) async {
  await db.updateUserPassword(user,password);
  await fetchAllUserAccounts();
  notifyListeners();
}
Future<void> getAllReports() async {
 allReports =  await db.getReportFromFB();
  notifyListeners();
}
Future<void> deleteReports(String rpId) async {
  await db.deleteReport(rpId);
  notifyListeners();
}
Future<void> updateStatusReports(Report report, String status) async {
  await db.updateReportStatus(report, status);
  notifyListeners();
}
Map<String, int> getReportCountsByConversation() {
  final Map<String, int> counts = {};
  for (final report in allReports) {
    counts[report.conservationId] = (counts[report.conservationId] ?? 0) + 1;
  }
  return counts;
}

String? getMostReportedConversation() {
  final counts = getReportCountsByConversation();
  if (counts.isEmpty) return null;
  return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
}
List<MapEntry<String, int>> getTopReportedConversations(int topN) {
  final Map<String, int> counts = {};
  for (final report in allReports) {
    counts[report.conservationId] = (counts[report.conservationId] ?? 0) + 1;
  }
  final sorted = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return sorted.take(topN).toList();
}
List<Report> getTodayReports() {
  final today = DateTime.now();
  final startOfDay = DateTime(today.year, today.month, today.day);
  return allReports
      .where((r) => r.time.isAfter(startOfDay))
      .toList();
}

List<MapEntry<String, int>> getTopReportedConversationsToday(int topN) {
  final counts = <String, int>{};
  for (var r in getTodayReports()) {
    counts[r.conservationId] = (counts[r.conservationId] ?? 0) + 1;
  }
  final sorted = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return sorted.take(topN).toList();
}

List<MapEntry<String, int>> getTopReportersToday(int topN) {
  final counts = <String, int>{};
  for (var r in getTodayReports()) {
    counts[r.reportedBy] = (counts[r.reportedBy] ?? 0) + 1;
  }
  final sorted = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return sorted.take(topN).toList();
}
Future<List<Message>> getAllMessagesFromRTDB() async
{
  return await db.getAllMessagesFromRTDB();
}
List<Report> getReportsBetweenDates(DateTime start, DateTime end) {
  return allReports.where((r) {
    return r.time.isAfter(start.subtract(const Duration(seconds: 1))) &&
           r.time.isBefore(end.add(const Duration(days: 1)));
  }).toList();
}

List<MapEntry<String, int>> getTopReportedConversationsBetweenDates(DateTime start, DateTime end, int topN) {
  final reports = getReportsBetweenDates(start, end);
  final counts = <String, int>{};
  for (var r in reports) {
    counts[r.conservationId] = (counts[r.conservationId] ?? 0) + 1;
  }
  final sorted = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return sorted.take(topN).toList();
}

List<MapEntry<String, int>> getTopReportersBetweenDates(DateTime start, DateTime end, int topN) {
  final reports = getReportsBetweenDates(start, end);
  final counts = <String, int>{};
  for (var r in reports) {
    counts[r.reportedBy] = (counts[r.reportedBy] ?? 0) + 1;
  }
  final sorted = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return sorted.take(topN).toList();
}

}
