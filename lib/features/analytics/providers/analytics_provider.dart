import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/database/isar_db.dart';
import '../../../core/database/models.dart';

class AnalyticsData {
  final double overallAccuracy;
  final Map<String, double> topicAccuracy;
  final Map<String, double> difficultyAccuracy;
  final List<String> weakTopics;
  final List<TestSessionModel> sessions;

  AnalyticsData({
    required this.overallAccuracy,
    required this.topicAccuracy,
    required this.difficultyAccuracy,
    required this.weakTopics,
    required this.sessions,
  });
}

final analyticsProvider = FutureProvider<AnalyticsData>((ref) async {
  final isar = IsarDb.instance;

  final attempts = await isar.attemptModels.where().findAll();
  final sessions = await isar.testSessionModels.where().sortByDate().findAll();

  if (attempts.isEmpty) {
    return AnalyticsData(overallAccuracy: 0, topicAccuracy: {}, difficultyAccuracy: {}, weakTopics: [], sessions: []);
  }

  int totalAttempts = attempts.length;
  int correctAttempts = attempts.where((a) => a.isCorrect).length;
  double overallAccuracy = (correctAttempts / totalAttempts) * 100;

  Map<String, int> topicTotal = {};
  Map<String, int> topicCorrect = {};
  Map<String, int> diffTotal = {};
  Map<String, int> diffCorrect = {};

  for (var attempt in attempts) {
    topicTotal[attempt.topic] = (topicTotal[attempt.topic] ?? 0) + 1;
    diffTotal[attempt.difficulty] = (diffTotal[attempt.difficulty] ?? 0) + 1;

    if (attempt.isCorrect) {
      topicCorrect[attempt.topic] = (topicCorrect[attempt.topic] ?? 0) + 1;
      diffCorrect[attempt.difficulty] = (diffCorrect[attempt.difficulty] ?? 0) + 1;
    }
  }

  Map<String, double> topicAccuracy = {};
  List<String> weakTopics = [];
  topicTotal.forEach((topic, total) {
    double acc = ((topicCorrect[topic] ?? 0) / total) * 100;
    topicAccuracy[topic] = acc;
    if (acc < 60) weakTopics.add(topic);
  });

  Map<String, double> difficultyAccuracy = {};
  diffTotal.forEach((diff, total) {
    difficultyAccuracy[diff] = ((diffCorrect[diff] ?? 0) / total) * 100;
  });

  return AnalyticsData(
    overallAccuracy: overallAccuracy,
    topicAccuracy: topicAccuracy,
    difficultyAccuracy: difficultyAccuracy,
    weakTopics: weakTopics,
    sessions: sessions,
  );
});