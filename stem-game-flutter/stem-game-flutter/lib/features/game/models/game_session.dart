import 'package:equatable/equatable.dart';

class GameSession extends Equatable {
  final int worldId;
  final String levelId;
  final DateTime startTime;
  final int currentQuestionIndex;
  final int score;
  final int hintsUsed;
  final int hintsRemaining;
  final List<bool> questionResults;
  final Map<String, String> userAnswers;
  final int currentHintLevel;

  const GameSession({
    required this.worldId,
    required this.levelId,
    required this.startTime,
    this.currentQuestionIndex = 0,
    this.score = 0,
    this.hintsUsed = 0,
    this.hintsRemaining = 3,
    this.questionResults = const [],
    this.userAnswers = const {},
    this.currentHintLevel = 0,
  });

  int get timeSpentSeconds => DateTime.now().difference(startTime).inSeconds;

  int get questionsAnswered => questionResults.length;

  int get correctAnswers => questionResults.where((r) => r).length;

  double get accuracy =>
      questionsAnswered > 0 ? correctAnswers / questionsAnswered : 0.0;

  GameSession copyWith({
    int? worldId,
    String? levelId,
    DateTime? startTime,
    int? currentQuestionIndex,
    int? score,
    int? hintsUsed,
    int? hintsRemaining,
    List<bool>? questionResults,
    Map<String, String>? userAnswers,
    int? currentHintLevel,
  }) {
    return GameSession(
      worldId: worldId ?? this.worldId,
      levelId: levelId ?? this.levelId,
      startTime: startTime ?? this.startTime,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      score: score ?? this.score,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      hintsRemaining: hintsRemaining ?? this.hintsRemaining,
      questionResults: questionResults ?? this.questionResults,
      userAnswers: userAnswers ?? this.userAnswers,
      currentHintLevel: currentHintLevel ?? this.currentHintLevel,
    );
  }

  @override
  List<Object?> get props => [
        worldId,
        levelId,
        startTime,
        currentQuestionIndex,
        score,
        hintsUsed,
        hintsRemaining,
        questionResults,
        userAnswers,
        currentHintLevel,
      ];
}
