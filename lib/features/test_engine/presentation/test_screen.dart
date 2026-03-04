import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/test_provider.dart';
import 'result_screen.dart';

class TestScreen extends ConsumerWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testState = ref.watch(testProvider);

    ref.listen<AsyncValue<TestState>>(testProvider, (previous, next) {
      next.whenData((state) {
        if (state.isFinished) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => ResultScreen(sessionId: state.sessionId)),
          );
        }
      });
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Test Attempt')),
      body: testState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (state) {
          if (state.mcqs.isEmpty) {
            return const Center(child: Text('No MCQs available. Please upload a PDF.'));
          }
          if (state.isFinished) {
            return const Center(child: CircularProgressIndicator());
          }

          final mcq = state.mcqs[state.currentIndex];
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Question ${state.currentIndex + 1}/${state.mcqs.length}'),
                    Text('Time: ${state.timerSeconds}s'),
                  ],
                ),
                const SizedBox(height: 20),
                Text(mcq.question, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ...List.generate(mcq.options.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      onPressed: () => ref.read(testProvider.notifier).submitAnswer(index),
                      child: Text(mcq.options[index]),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}