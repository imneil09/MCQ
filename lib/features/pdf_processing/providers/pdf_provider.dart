import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../repository/pdf_repository.dart';

final pdfRepositoryProvider = Provider((ref) => PdfRepository());

final pdfProcessingProvider = StateNotifierProvider<PdfProcessingNotifier, AsyncValue<void>>((ref) {
  return PdfProcessingNotifier(ref.watch(pdfRepositoryProvider));
});

class PdfProcessingNotifier extends StateNotifier<AsyncValue<void>> {
  final PdfRepository _repository;

  PdfProcessingNotifier(this._repository) : super(const AsyncData(null));

  Future<void> pickAndProcessPdf() async {
    state = const AsyncLoading();
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        String path = result.files.single.path!;
        String text = await _repository.extractTextFromPdf(path);
        await _repository.processAndSaveMCQs(text);
        state = const AsyncData(null);
      } else {
        state = AsyncError(Exception('No file selected'), StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}