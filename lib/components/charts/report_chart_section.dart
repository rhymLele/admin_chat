// file: widgets/report_chart_section.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:admin_user/model/report.dart';

class ReportChartSection extends StatelessWidget {
  final List<Report> reports;

  const ReportChartSection({super.key, required this.reports});

  Map<String, int> getStatusCounts() {
    final counts = <String, int>{'pending': 0, 'resolved': 0};
    for (final r in reports) {
      if (counts.containsKey(r.status)) {
        counts[r.status] = counts[r.status]! + 1;
      }
    }
    return counts;
  }

  Map<String, int> getDayCounts() {
    final dayMap = <String, int>{};
    for (final r in reports) {
      final dateStr = "${r.time.year}-${r.time.month.toString().padLeft(2, '0')}-${r.time.day.toString().padLeft(2, '0')}";
      dayMap[dateStr] = (dayMap[dateStr] ?? 0) + 1;
    }
    return dayMap;
  }

  @override
  Widget build(BuildContext context) {
    final statusData = getStatusCounts();
    final dayData = getDayCounts();
    final sortedDays = dayData.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("Report Status Pie Chart", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        AspectRatio(
          aspectRatio: 1.4,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  color: Colors.orange,
                  value: statusData['pending']?.toDouble() ?? 0,
                  title: 'Pending (${statusData['pending']})',
                ),
                PieChartSectionData(
                  color: Colors.green,
                  value: statusData['resolved']?.toDouble() ?? 0,
                  title: 'Resolved (${statusData['resolved']})',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text("Reports by Day", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final dayIdx = value.toInt();
                      if (dayIdx < 0 || dayIdx >= sortedDays.length) return const SizedBox();
                      final label = sortedDays[dayIdx].split('-').last;
                      return Text(label);
                    },
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
              ),
              barGroups: List.generate(sortedDays.length, (i) {
                final count = dayData[sortedDays[i]] ?? 0;
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(toY: count.toDouble(), color: Colors.blue),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
