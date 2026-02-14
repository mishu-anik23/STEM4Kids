import 'package:equatable/equatable.dart';

abstract class GameEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadLevelEvent extends GameEvent {
  final int worldId;
  final String levelId;

  LoadLevelEvent(this.worldId, this.levelId);

  @override
  List<Object?> get props => [worldId, levelId];
}

class SubmitAnswerEvent extends GameEvent {
  final String questionId;
  final String answer;

  SubmitAnswerEvent(this.questionId, this.answer);

  @override
  List<Object?> get props => [questionId, answer];
}

class RequestHintEvent extends GameEvent {
  final String questionId;

  RequestHintEvent(this.questionId);

  @override
  List<Object?> get props => [questionId];
}

class NextQuestionEvent extends GameEvent {}

class CompleteLevelEvent extends GameEvent {}

class RestartLevelEvent extends GameEvent {}

// --- New challenge-based events ---

class StartChallengeEvent extends GameEvent {}

class UpdateChallengeProgressEvent extends GameEvent {
  final Map<String, dynamic> progressData;
  final int currentScore;

  UpdateChallengeProgressEvent(this.progressData, this.currentScore);

  @override
  List<Object?> get props => [progressData, currentScore];
}

class CompleteChallengeEvent extends GameEvent {
  final Map<String, dynamic> results;

  CompleteChallengeEvent(this.results);

  @override
  List<Object?> get props => [results];
}

class RequestChallengeHintEvent extends GameEvent {}
