import 'package:flutter/material.dart';
import '../../../core/database/isar_db.dart';
import '../../../core/database/models.dart';
import 'package:isar/isar.dart';

class ResultScreen extends StatelessWidget {
  final String sessionId;
  const ResultScreen({super.key, required this.sessionId});

  Future<TestSessionModel?> _fetchSession() async {
    return await IsarDb.instance.testSessionModels.filter().sessionIdEqualTo(sessionId).findFirst();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Result')),
      body: FutureBuilder<TestSessionModel?>(
        future: _fetchSession(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Result not found'));
          }
          final session = snapshot.data!;
          final accuracy = session.totalQuestions > 0
              ? (session.totalScore / session.totalQuestions) * 100
              : 0.0;
          final avgTime = session.totalQuestions > 0
              ? session.totalTimeSeconds / session.totalQuestions
              : 0.0;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Score: ${session.totalScore} / ${session.totalQuestions}', style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 10),
                Text('Accuracy: ${accuracy.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 10),
                Text('Average Time per Question: ${avgTime.toStringAsFixed(1)}s', style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}