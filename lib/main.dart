import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/database/isar_db.dart';
import 'features/pdf_processing/presentation/pdf_upload_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarDb.init();
  runApp(const ProviderScope(child: AIMCQAnalyzerApp()));
}

class AIMCQAnalyzerApp extends StatelessWidget {
  const AIMCQAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI MCQ Analyzer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PdfUploadScreen(),
    );
  }
}