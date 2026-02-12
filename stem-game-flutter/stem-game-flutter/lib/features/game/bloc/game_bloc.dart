import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/level_repository.dart';
import '../../../core/utils/score_calculator.dart';
import '../../../core/utils/answer_validator.dart';
import '../models/level_data.dart';
import '../models/game_session.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final LevelRepository levelRepository;
  LevelData? _currentLevelData;
  GameSession? _currentSession;

  GameBloc(this.levelRepository) : super(GameInitial()) {
    on<LoadLevelEvent>(_onLoadLevel);
    on<SubmitAnswerEvent>(_onSubmitAnswer);
    on<RequestHintEvent>(_onRequestHint);
    on<NextQuestionEvent>(_onNextQuestion);
    on<CompleteLevelEvent>(_onCompleteLevel);
    on<RestartLevelEvent>(_onRestartLevel);
  }

  Future<void> _onLoadLevel(
    LoadLevelEvent event,
    Emitter<GameState> emit,
  ) async {
    try {
      emit(GameLoading());

      final levelData = await levelRepository.loadLevel(
        event.worldId,
        event.levelId,
      );

      final session = GameSession(
        worldId: event.worldId,
        levelId: event.levelId,
        startTime: DateTime.now(),
      );

      _currentLevelData = levelData;
      _currentSession = session;

      emit(GameReady(levelData, session));
    } catch (e) {
      emit(GameError('Failed to load level: $e'));
    }
  }

  Future<void> _onSubmitAnswer(
    SubmitAnswerEvent event,
    Emitter<GameState> emit,
  ) async {
    if (_currentLevelData == null || _currentSession == null) {
      return;
    }

    final currentQuestion = _currentLevelData!.questions[_currentSession!.currentQuestionIndex];
    final isCorrect = AnswerValidator.validateAnswer(
      event.answer,
      currentQuestion.correctAnswer,
    );

    final updatedResults = List<bool>.from(_currentSession!.questionResults)..add(isCorrect);
    final updatedAnswers = Map<String, String>.from(_currentSession!.userAnswers);
    updatedAnswers[event.questionId] = event.answer;

    final newScore = _currentSession!.score + (isCorrect ? ScoreCalculator.pointsPerQuestion : 0);

    _currentSession = _currentSession!.copyWith(
      questionResults: updatedResults,
      userAnswers: updatedAnswers,
      score: newScore,
      currentHintLevel: 0,
      currentQuestionIndex: _currentSession!.currentQuestionIndex + 1,
    );

    emit(AnswerSubmitted(
      isCorrect: isCorrect,
      correctAnswer: currentQuestion.correctAnswer,
      explanation: currentQuestion.explanation,
      newScore: newScore,
      levelData: _currentLevelData!,
      session: _currentSession!,
      currentQuestion: currentQuestion,
      questionIndex: _currentSession!.currentQuestionIndex - 1,
    ));
  }

  Future<void> _onRequestHint(
    RequestHintEvent event,
    Emitter<GameState> emit,
  ) async {
    if (_currentLevelData == null || _currentSession == null) {
      return;
    }

    if (_currentSession!.hintsRemaining <= 0) {
      return;
    }

    final currentQuestion = _currentLevelData!.questions[_currentSession!.currentQuestionIndex];
    final hintLevel = _currentSession!.currentHintLevel;

    if (hintLevel >= currentQuestion.hints.length) {
      return;
    }

    final hint = currentQuestion.hints[hintLevel];

    _currentSession = _currentSession!.copyWith(
      hintsUsed: _currentSession!.hintsUsed + 1,
      hintsRemaining: _currentSession!.hintsRemaining - 1,
      currentHintLevel: hintLevel + 1,
    );

    emit(HintDisplayed(
      hint: hint,
      hintsRemaining: _currentSession!.hintsRemaining,
      levelData: _currentLevelData!,
      session: _currentSession!,
      currentQuestion: currentQuestion,
      questionIndex: _currentSession!.currentQuestionIndex,
    ));
  }

  Future<void> _onNextQuestion(
    NextQuestionEvent event,
    Emitter<GameState> emit,
  ) async {
    if (_currentLevelData == null || _currentSession == null) {
      return;
    }

    if (_currentSession!.currentQuestionIndex >= _currentLevelData!.totalQuestions) {
      add(CompleteLevelEvent());
      return;
    }

    final question = _currentLevelData!.questions[_currentSession!.currentQuestionIndex];

    emit(QuestionActive(
      _currentLevelData!,
      _currentSession!,
      question,
      _currentSession!.currentQuestionIndex,
    ));
  }

  Future<void> _onCompleteLevel(
    CompleteLevelEvent event,
    Emitter<GameState> emit,
  ) async {
    if (_currentSession == null) {
      return;
    }

    final finalScore = _currentSession!.score;
    final stars = ScoreCalculator.calculateStars(finalScore);
    final coinsEarned = ScoreCalculator.calculateCoins(stars, _currentSession!.hintsUsed);
    final timeSpent = _currentSession!.timeSpentSeconds;
    final hintsUsed = _currentSession!.hintsUsed;

    emit(LevelCompleted(
      finalScore: finalScore,
      stars: stars,
      coinsEarned: coinsEarned,
      timeSpent: timeSpent,
      hintsUsed: hintsUsed,
      isNewBest: true,
      worldId: _currentSession!.worldId,
      levelId: _currentSession!.levelId,
    ));
  }

  Future<void> _onRestartLevel(
    RestartLevelEvent event,
    Emitter<GameState> emit,
  ) async {
    if (_currentSession == null) {
      return;
    }

    add(LoadLevelEvent(_currentSession!.worldId, _currentSession!.levelId));
  }
}
