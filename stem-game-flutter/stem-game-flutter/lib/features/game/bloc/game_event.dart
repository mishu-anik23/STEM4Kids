import 'package:equatable/equatable.dart';

abstract class GameEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadLevelEvent extends GameEvent {
  final int worldId;
  final int levelId;

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
