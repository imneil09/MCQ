import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models.dart';

class IsarDb {
  static late Isar instance;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    instance = await Isar.open(
      [MCQModelSchema, AttemptModelSchema, TestSessionModelSchema],
      directory: dir.path,
    );
  }
}