import 'package:equatable/equatable.dart';
import 'challenge_data.dart';

class ChallengeSession extends Equatable {
  final int worldId;
  final String levelId;
  final ChallengeType challengeType;
  final DateTime startTime;
  final int score;
  final int maxScore;
  final bool isCompleted;
  final int hintsUsed;
  final int hintsRemaining;
  final Map<String, dynamic> progressData;

  const ChallengeSession({
    required this.worldId,
    required this.levelId,
    required this.challengeType,
    required this.startTime,
    this.score = 0,
    this.maxScore = 100,
    this.isCompleted = false,
    this.hintsUsed = 0,
    this.hintsRemaining = 3,
    this.progressData = const {},
  });

  int get timeSpentSeconds => DateTime.now().difference(startTime).inSeconds;

  double get completionPercent =>
      maxScore > 0 ? score / maxScore : 0.0;

  ChallengeSession copyWith({
    int? worldId,
    String? levelId,
    ChallengeType? challengeType,
    DateTime? startTime,
    int? score,
    int? maxScore,
    bool? isCompleted,
    int? hintsUsed,
    int? hintsRemaining,
    Map<String, dynamic>? progressData,
  }) {
    return ChallengeSession(
      worldId: worldId ?? this.worldId,
      levelId: levelId ?? this.levelId,
      challengeType: challengeType ?? this.challengeType,
      startTime: startTime ?? this.startTime,
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      isCompleted: isCompleted ?? this.isCompleted,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      hintsRemaining: hintsRemaining ?? this.hintsRemaining,
      progressData: progressData ?? this.progressData,
    );
  }

  @override
  List<Object?> get props => [
        worldId,
        levelId,
        challengeType,
        startTime,
        score,
        maxScore,
        isCompleted,
        hintsUsed,
        hintsRemaining,
        progressData,
      ];
}
