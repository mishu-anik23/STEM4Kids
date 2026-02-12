import 'package:equatable/equatable.dart';
import '../models/level_data.dart';
import '../models/game_session.dart';

abstract class GameState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GameInitial extends GameState {}

class GameLoading extends GameState {}

class GameReady extends GameState {
  final LevelData levelData;
  final GameSession session;

  GameReady(this.levelData, this.session);

  @override
  List<Object?> get props => [levelData, session];
}

class QuestionActive extends GameState {
  final LevelData levelData;
  final GameSession session;
  final Question currentQuestion;
  final int questionIndex;

  QuestionActive(
    this.levelData,
    this.session,
    this.currentQuestion,
    this.questionIndex,
  );

  @override
  List<Object?> get props => [levelData, session, currentQuestion, questionIndex];
}

class AnswerSubmitted extends GameState {
  final bool isCorrect;
  final String correctAnswer;
  final String explanation;
  final int newScore;
  final LevelData levelData;
  final GameSession session;
  final Question currentQuestion;
  final int questionIndex;

  AnswerSubmitted({
    required this.isCorrect,
    required this.correctAnswer,
    required this.explanation,
    required this.newScore,
    required this.levelData,
    required this.session,
    required this.currentQuestion,
    required this.questionIndex,
  });

  @override
  List<Object?> get props => [
        isCorrect,
        correctAnswer,
        explanation,
        newScore,
        levelData,
        session,
        currentQuestion,
        questionIndex,
      ];
}

class HintDisplayed extends GameState {
  final Hint hint;
  final int hintsRemaining;
  final LevelData levelData;
  final GameSession session;
  final Question currentQuestion;
  final int questionIndex;

  HintDisplayed({
    required this.hint,
    required this.hintsRemaining,
    required this.levelData,
    required this.session,
    required this.currentQuestion,
    required this.questionIndex,
  });

  @override
  List<Object?> get props => [
        hint,
        hintsRemaining,
        levelData,
        session,
        currentQuestion,
        questionIndex,
      ];
}

class LevelCompleted extends GameState {
  final int finalScore;
  final int stars;
  final int coinsEarned;
  final int timeSpent;
  final int hintsUsed;
  final bool isNewBest;
  final int worldId;
  final int levelId;

  LevelCompleted({
    required this.finalScore,
    required this.stars,
    required this.coinsEarned,
    required this.timeSpent,
    required this.hintsUsed,
    required this.isNewBest,
    required this.worldId,
    required this.levelId,
  });

  @override
  List<Object?> get props => [
        finalScore,
        stars,
        coinsEarned,
        timeSpent,
        hintsUsed,
        isNewBest,
        worldId,
        levelId,
      ];
}

class GameError extends GameState {
  final String message;

  GameError(this.message);

  @override
  List<Object?> get props => [message];
}
