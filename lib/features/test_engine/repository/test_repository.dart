import '../../../core/database/isar_db.dart';
import '../../../core/database/models.dart';
import 'package:isar/isar.dart';

class TestRepository {
  final Isar _isar = IsarDb.instance;

  Future<List<MCQModel>> fetchAllMCQs() async {
    return await _isar.mCQModels.where().findAll();
  }

  Future<void> saveAttempt(AttemptModel attempt) async {
    await _isar.writeTxn(() async {
      await _isar.attemptModels.put(attempt);
    });
  }

  Future<void> saveTestSession(TestSessionModel session) async {
    await _isar.writeTxn(() async {
      await _isar.testSessionModels.put(session);
    });
  }
}