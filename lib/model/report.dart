import 'package:cloud_firestore/cloud_firestore.dart';

class Report{
   final String documentId; //
  String conservationId;
  String messageReport;
  String reportedBy;
  DateTime time;
  final String status;
   Report({
      required this.documentId,
    required this.conservationId,
    required this.messageReport,
    required this.reportedBy,
    required this.time,
    required this.status,
  });
   factory Report.fromDocument(DocumentSnapshot doc) {
     final data = doc.data() as Map<String, dynamic>;
    return Report(
      documentId: doc.id, // <-- lấy id
      conservationId: doc['conservationId'] ?? '',
      messageReport: doc['messageReport'] ?? '',
      reportedBy: doc['reportedBy']??'',
      time: (doc['timestamp'] as Timestamp).toDate(),
          status: data['status'] ?? 'pending',
    );
  }
   Map<String,dynamic> toMap()
  {return {
      'conservationId': conservationId,
      'messageReport': messageReport,
      'reportedBy': reportedBy,
      'timestamp': time,
        'status': status,
    };}
}