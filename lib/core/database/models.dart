import 'package:isar/isar.dart';

part 'models.g.dart';

@collection
class MCQModel {
  Id isarId = Isar.autoIncrement;
  late String id;
  late String question;
  late List<String> options;
  late int correctIndex;
  late String topic;
  late String difficulty;
}

@collection
class AttemptModel {
  Id isarId = Isar.autoIncrement;
  late String attemptId;
  late String sessionId;
  late String mcqId;
  late int selectedIndex;
  late bool isCorrect;
  late int timeTakenSeconds;

  @Index()
  late String topic;

  @Index()
  late String difficulty;
}

@collection
class TestSessionModel {
  Id isarId = Isar.autoIncrement;
  late String sessionId;
  late DateTime date;
  late int totalScore;
  late int totalQuestions;
  late int totalTimeSeconds;
}