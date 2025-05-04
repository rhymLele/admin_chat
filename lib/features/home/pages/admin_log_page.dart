import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_user/services/logger/logger_service.dart';

class AdminLogPage extends StatelessWidget {
  final logger = LoggerService();

  AdminLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Action Logs")),
      body: StreamBuilder<QuerySnapshot>(
        stream: logger.getAdminLogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No logs found"));
          }

          final logs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final data = logs[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['action'] ?? ''),
                subtitle: Text((data['details'] ?? {}).toString()),
                trailing: Text(
                  (data['timestamp'] as Timestamp?)?.toDate().toString() ?? '',
                  style: const TextStyle(fontSize: 12),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
