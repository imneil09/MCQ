import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../repository/test_repository.dart';
import '../../../core/database/models.dart';

final testRepositoryProvider = Provider((ref) => TestRepository());

class TestState {
  final List<MCQModel> mcqs;
  final int currentIndex;
  final int timerSeconds;
  final String sessionId;
  final Map<String, AttemptModel> attempts;
  final bool isFinished;

  TestState({
    required this.mcqs,
    required this.currentIndex,
    required this.timerSeconds,
    required this.sessionId,
    required this.attempts,
    required this.isFinished,
  });

  TestState copyWith({
    List<MCQModel>? mcqs,
    int? currentIndex,
    int? timerSeconds,
    String? sessionId,
    Map<String, AttemptModel>? attempts,
    bool? isFinished,
  }) {
    return TestState(
      mcqs: mcqs ?? this.mcqs,
      currentIndex: currentIndex ?? this.currentIndex,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      sessionId: sessionId ?? this.sessionId,
      attempts: attempts ?? this.attempts,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}

final testProvider = StateNotifierProvider<TestNotifier, AsyncValue<TestState>>((ref) {
  return TestNotifier(ref.watch(testRepositoryProvider));
});

class TestNotifier extends StateNotifier<AsyncValue<TestState>> {
  final TestRepository _repository;
  Timer? _timer;

  TestNotifier(this._repository) : super(const AsyncLoading()) {
    _initTest();
  }

  Future<void> _initTest() async {
    try {
      final mcqs = await _repository.fetchAllMCQs();
      state = AsyncData(TestState(
        mcqs: mcqs,
        currentIndex: 0,
        timerSeconds: 0,
        sessionId: const Uuid().v4(),
        attempts: {},
        isFinished: false,
      ));
      _startTimer();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state.whenData((current) {
        if (!current.isFinished) {
          state = AsyncData(current.copyWith(timerSeconds: current.timerSeconds + 1));
        }
      });
    });
  }

  Future<void> submitAnswer(int selectedIndex) async {
    state.whenData((current) async {
      final mcq = current.mcqs[current.currentIndex];
      final isCorrect = selectedIndex == mcq.correctIndex;

      final attempt = AttemptModel()
        ..attemptId = const Uuid().v4()
        ..sessionId = current.sessionId
        ..mcqId = mcq.id
        ..selectedIndex = selectedIndex
        ..isCorrect = isCorrect
        ..timeTakenSeconds = current.timerSeconds
        ..topic = mcq.topic
        ..difficulty = mcq.difficulty;

      await _repository.saveAttempt(attempt);

      final newAttempts = Map<String, AttemptModel>.from(current.attempts);
      newAttempts[mcq.id] = attempt;

      if (current.currentIndex < current.mcqs.length - 1) {
        state = AsyncData(current.copyWith(
          attempts: newAttempts,
          currentIndex: current.currentIndex + 1,
          timerSeconds: 0,
        ));
      } else {
        _timer?.cancel();
        int score = newAttempts.values.where((a) => a.isCorrect).length;
        int totalTime = newAttempts.values.fold(0, (sum, a) => sum + a.timeTakenSeconds);

        final session = TestSessionModel()
          ..sessionId = current.sessionId
          ..date = DateTime.now()
          ..totalScore = score
          ..totalQuestions = current.mcqs.length
          ..totalTimeSeconds = totalTime;

        await _repository.saveTestSession(session);

        state = AsyncData(current.copyWith(
          attempts: newAttempts,
          isFinished: true,
        ));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}