import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/analytics_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsState = ref.watch(analyticsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Performance Analytics')),
      body: analyticsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (data) {
          if (data.sessions.isEmpty) {
            return const Center(child: Text('No data available. Complete a test first.'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Overall Accuracy: ${data.overallAccuracy.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Text('Weak Topics (<60%):', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ...data.weakTopics.map((t) => Text('- $t', style: const TextStyle(color: Colors.red))),
                const SizedBox(height: 30),
                const Text('Progress Over Time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true),
                      titlesData: const FlTitlesData(
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: data.sessions.asMap().entries.map((e) {
                            double accuracy = e.value.totalQuestions > 0
                                ? (e.value.totalScore / e.value.totalQuestions) * 100
                                : 0.0;
                            return FlSpot(e.key.toDouble(), accuracy);
                          }).toList(),
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 3,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text('Topic-wise Accuracy:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ...data.topicAccuracy.entries.map((e) => Text('${e.key}: ${e.value.toStringAsFixed(1)}%')),
                const SizedBox(height: 20),
                const Text('Difficulty-wise Accuracy:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ...data.difficultyAccuracy.entries.map((e) => Text('${e.key}: ${e.value.toStringAsFixed(1)}%')),
              ],
            ),
          );
        },
      ),
    );
  }
}