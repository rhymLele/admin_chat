  // File: lib/pages/report_page.dart

  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import 'package:admin_user/components/drawer/my_drawer.dart';
  import 'package:admin_user/services/database/database_provider.dart';
  import 'package:admin_user/model/report.dart';
  import 'package:intl/intl.dart';
  import 'package:csv/csv.dart';
  import 'dart:convert';
  import 'dart:html' as html; // ⬅️ Add this only for web

  class ReportPage extends StatefulWidget {
    const ReportPage({super.key});

    @override
    State<ReportPage> createState() => _ReportPageState();
  }

  class _ReportPageState extends State<ReportPage> {
    List<Report> allReports = [];
    List<Report> filteredReports = [];
    bool isLoading = false;
    final searchController = TextEditingController();
    String selectedStatus = 'pending';
    DateTimeRange? selectedDateRange;
    List<MapEntry<String, int>> top3Conversations = [];
    List<MapEntry<String, int>> top3Reporters = [];

    late final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);

    @override
    void initState() {
      super.initState();
      loadReports();
      searchController.addListener(applyFilters);
    }

    Future<void> deleteReport(Report report) async {
      setState(() => isLoading = true);
      await dbProvider.deleteReports(report.documentId);
      await loadReports();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Report deleted")));
    }

    Future<void> toggleReportStatus(Report report) async {
      if (report.status == 'resolved') {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Confirm revert"),
            content:
                const Text("Do you want to mark this report as pending again?"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Confirm")),
            ],
          ),
        );
        if (confirmed != true) return;
        setState(() => isLoading = true);
        await dbProvider.updateStatusReports(report, 'pending');
      } else {
        setState(() => isLoading = true);
        await dbProvider.updateStatusReports(report, 'resolved');
      }
      await loadReports();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Report marked as ${report.status == 'resolved' ? 'pending' : 'resolved'}")),
      );
    }

    void applyFilters() {
      final query = searchController.text.toLowerCase();
      setState(() {
        filteredReports = allReports.where((r) {
          final matchesQuery = r.reportedBy.toLowerCase().contains(query) ||
              r.messageReport.toLowerCase().contains(query);
          final matchesStatus =
              selectedStatus == 'all' || r.status == selectedStatus;
          final matchesDate = selectedDateRange == null ||
              (r.time.isAfter(selectedDateRange!.start) &&
                  r.time.isBefore(selectedDateRange!.end));
          return matchesQuery && matchesStatus && matchesDate;
        }).toList();
      });
      final conversationCount = <String, int>{};
      for (final report in filteredReports) {
        conversationCount[report.conservationId] =
            (conversationCount[report.conservationId] ?? 0) + 1;
      }
      top3Conversations = conversationCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      top3Conversations = top3Conversations.take(3).toList();

  // Top 3 reporters (to detect possible spamming)
      final reporterCount = <String, int>{};
      for (final report in filteredReports) {
        reporterCount[report.reportedBy] =
            (reporterCount[report.reportedBy] ?? 0) + 1;
      }
      top3Reporters = reporterCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      top3Reporters = top3Reporters.take(3).toList();
    }

    Future<void> loadReports() async {
      setState(() => isLoading = true);
      await dbProvider.getAllReports();
      allReports = dbProvider.allReports;
      applyFilters();
      setState(() => isLoading = false);
    }

    Future<void> exportToCSV() async {
      try {
        List<List<dynamic>> rows = [
          ['Reporter', 'Message', 'Status', 'Time']
        ];

        for (var report in filteredReports) {
          rows.add([
            report.reportedBy,
            report.messageReport,
            report.status,
            DateFormat.yMd().add_jm().format(report.time),
          ]);
        }

        final csv = const ListToCsvConverter().convert(rows);
        final bytes = utf8.encode(csv);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'reports_export.csv')
          ..click();
        html.Url.revokeObjectUrl(url);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CSV download started')),
        );
      } catch (e) {
        debugPrint("CSV export error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export CSV: $e')),
        );
      }
    }

    @override
    Widget build(BuildContext context) {
      final pendingCount = allReports.where((r) => r.status == 'pending').length;
      final resolvedCount =
          allReports.where((r) => r.status == 'resolved').length;
      final top3Conversations = dbProvider.getTopReportedConversations(3);

      return Scaffold(
        appBar: AppBar(
          title: const Text("Reported Messages"),
          actions: [
            if (pendingCount > 100)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                    child: Text('🚨 High pending reports!',
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold))),
              ),
            IconButton(
              icon: const Icon(Icons.download),
              tooltip: 'Export to CSV',
              onPressed: exportToCSV,
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(children: [
                    
            if (top3Conversations.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  height: 160,
                  width: 300,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    color: Colors.blueGrey.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("🔝 Top 3 Reported Conversations:",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          ...top3Conversations.map(
                            (e) => Text("• ${e.key} - ${e.value} reports",
                                style: const TextStyle(fontSize: 14)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (top3Reporters.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  height: 160,
                  width: 300,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("👤 Top 3 Frequent Reporters:",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          ...top3Reporters.map(
                            (e) => Text("• ${e.key} - ${e.value} reports",
                                style: const TextStyle(fontSize: 14)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            
                  ],),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryCard(
                          'Total', allReports.length, Colors.blueGrey),
                      _buildSummaryCard('Pending', pendingCount, Colors.orange),
                      _buildSummaryCard('Resolved', resolvedCount, Colors.green),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ExpansionTile(
                    title: const Text('Advanced Filter'),
                    children: [
                      TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by reporter or message...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text("Status:"),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            value: selectedStatus,
                            items: const [
                              DropdownMenuItem(value: 'all', child: Text("All")),
                              DropdownMenuItem(
                                  value: 'pending', child: Text("Pending")),
                              DropdownMenuItem(
                                  value: 'resolved', child: Text("Resolved")),
                            ],
                            onChanged: (value) {
                              setState(() => selectedStatus = value!);
                              applyFilters();
                            },
                          ),
                          const SizedBox(width: 16),
                          TextButton.icon(
                            icon: const Icon(Icons.date_range),
                            label: const Text("Select Date"),
                            onPressed: () async {
                              final range = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (range != null) {
                                setState(() => selectedDateRange = range);
                                applyFilters();
                              }
                            },
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredReports.isEmpty
                      ? const Center(child: Text("No reports found"))
                      : ListView.builder(
                          itemCount: filteredReports.length,
                          itemBuilder: (context, index) {
                            final report = filteredReports[index];
                            return Card(
                              color: report.status == 'pending'
                                  ? Colors.orange.shade50
                                  : Colors.green.shade50,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: ListTile(
                                title: Text(report.messageReport),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Reported by: ${report.reportedBy}"),
                                    Text(
                                        "Time: ${DateFormat.yMd().add_jm().format(report.time)}"),
                                    Text("Status: ${report.status}"),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Tooltip(
                                      message: report.status == 'pending'
                                          ? 'Mark as resolved'
                                          : 'Revert to pending',
                                      child: Checkbox(
                                        value: report.status == 'resolved',
                                        onChanged: (_) =>
                                            toggleReportStatus(report),
                                            
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () => deleteReport(report),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      );
    }

    Widget _buildSummaryCard(String title, int count, Color color) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(title,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(count.toString(),
                  style:
                      const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );
    }
  }
