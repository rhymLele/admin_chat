import 'package:admin_user/components/drawer/my_drawer.dart';
import 'package:admin_user/model/message.dart';
import 'package:admin_user/services/database/database_provider.dart';
import 'package:admin_user/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AdminBoard extends StatefulWidget {
  const AdminBoard({super.key});

  @override
  State<AdminBoard> createState() => _AdminBoardState();
}

class _AdminBoardState extends State<AdminBoard> {
  DateTime? selectedDate;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
    dbProvider.getAllReports();
    dbProvider.fetchAllUserAccounts();
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(
      builder: (context, dbProvider, _) {
        final topConversations = (_startDate != null && _endDate != null)
            ? dbProvider.getTopReportedConversationsBetweenDates(_startDate!, _endDate!, 3)
            : dbProvider.getTopReportedConversations(3);

        final topReporters = (_startDate != null && _endDate != null)
            ? dbProvider.getTopReportersBetweenDates(_startDate!, _endDate!, 3)
            : dbProvider.getTopReportedConversations(3);

        return Scaffold(
          appBar: AppBar(title: const Text("📊 Admin Dashboard")),
          drawer: MyDrawer(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text("📅 Filter by Date Range: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _selectDateRange,
                      child: Text(
                        _startDate != null && _endDate != null
                            ? "${DateFormat('dd/MM/yyyy').format(_startDate!)} - ${DateFormat('dd/MM/yyyy').format(_endDate!)}"
                            : "Select Date Range",
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_startDate != null && _endDate != null)
                      TextButton(
                        onPressed: () => setState(() {
                          _startDate = null;
                          _endDate = null;
                        }),
                        child: const Text("Clear", style: TextStyle(color: Colors.red)),
                      )
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    if (topConversations.isNotEmpty)
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2 - 24,
                        child: _buildCompactCard(
                          title: "🔝 Top 3 Conversations",
                          items: topConversations
                              .map((e) => "• ${e.key}: ${e.value}")
                              .toList(),
                          color: MyAppColor.primaryBg,
                        ),
                      ),
                    if (topReporters.isNotEmpty)
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2 - 24,
                        child: _buildCompactCard(
                          title: "👤 Top 3 Reporters",
                          items: topReporters
                              .map((e) => "• ${e.key}: ${e.value}")
                              .toList(),
                          color: MyAppColor.primaryBg,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                FutureBuilder<List<Message>>(
                  future: dbProvider.getAllMessagesFromRTDB(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final messages = snapshot.data!.take(10).toList();

                    return _buildCard(
                      title: "✉️ Latest Messages:",
                      children: messages.map((m) {
                        final formattedDate =
                            "${m.time.day.toString().padLeft(2, '0')}/"
                            "${m.time.month.toString().padLeft(2, '0')}/"
                            "${m.time.year} ${m.time.hour.toString().padLeft(2, '0')}:"
                            "${m.time.minute.toString().padLeft(2, '0')}";
                        return ListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          title: Text("${m.senderId} → ${m.receiverId}"),
                          subtitle: Text(m.message),
                          trailing: Text(formattedDate,
                              style: const TextStyle(fontSize: 12)),
                        );
                      }).toList(),
                      color: Colors.green.shade50,
                      height: 350,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactCard({
    required String title,
    required List<String> items,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            ...items
                .map((text) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child:
                          Text(text, style: const TextStyle(fontSize: 13)),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required List<Widget> children,
    required Color color,
    required double height,
  }) {
    return SizedBox(
      height: height,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 3,
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(children: children),
              ),
            ],
          ),
        ),
      ),
    );
  }
}