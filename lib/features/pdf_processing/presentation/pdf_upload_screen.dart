import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pdf_provider.dart';
import '../../test_engine/presentation/test_screen.dart';
import '../../analytics/presentation/analytics_screen.dart';

class PdfUploadScreen extends ConsumerWidget {
  const PdfUploadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final processingState = ref.watch(pdfProcessingProvider);

    ref.listen<AsyncValue<void>>(pdfProcessingProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        ),
        data: (_) {
          if (previous is AsyncLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('MCQs Generated and Saved!')),
            );
          }
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('AI MCQ Analyzer')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (processingState is AsyncLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton.icon(
                onPressed: () => ref.read(pdfProcessingProvider.notifier).pickAndProcessPdf(),
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload PDF Question Paper'),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TestScreen()));
              },
              child: const Text('Start Test'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen()));
              },
              child: const Text('View Analytics'),
            ),
          ],
        ),
      ),
    );
  }
}