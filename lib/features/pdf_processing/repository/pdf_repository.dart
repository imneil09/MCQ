import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../../core/utils/text_chunker.dart';
import '../../../services/gemini_service.dart';
import '../../../core/database/isar_db.dart';
import '../../../core/database/models.dart';

class PdfRepository {
  final GeminiService _geminiService = GeminiService();

  Future<String> extractTextFromPdf(String path) async {
    final File file = File(path);
    final List<int> bytes = await file.readAsBytes();
    final PdfDocument document = PdfDocument(inputBytes: bytes);
    String text = PdfTextExtractor(document).extractText();
    document.dispose();
    return text.replaceAll(RegExp(r'\s+'), ' ');
  }

  Future<void> processAndSaveMCQs(String text) async {
    final chunks = TextChunker.chunkText(text);
    final isar = IsarDb.instance;

    for (var chunk in chunks) {
      if (chunk.isEmpty) continue;
      final mcqs = await _geminiService.convertTextToMCQ(chunk);
      if (mcqs.isNotEmpty) {
        await isar.writeTxn(() async {
          await isar.mCQModels.putAll(mcqs);
        });
      }
    }
  }
}