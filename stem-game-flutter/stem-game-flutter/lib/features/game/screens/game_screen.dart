import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../models/level_data.dart';
import '../models/challenge_data.dart';
import '../widgets/game_header.dart';
import '../widgets/challenge_header.dart';
import '../widgets/answer_feedback.dart';
import '../widgets/question_widgets/multiple_choice_widget.dart';
import '../widgets/question_widgets/fill_blank_widget.dart';
import '../widgets/question_widgets/drag_drop_widget.dart';
import '../widgets/challenge_widgets/tap_objects_widget.dart';
import '../widgets/challenge_widgets/sort_items_widget.dart';
import '../widgets/challenge_widgets/path_finding_widget.dart';
import '../widgets/challenge_widgets/puzzle_widget.dart';
import '../widgets/challenge_widgets/memory_game_widget.dart';
import '../widgets/challenge_widgets/matching_widget.dart';
import '../widgets/challenge_widgets/sequencing_widget.dart';
import '../widgets/challenge_widgets/challenge_multiple_choice_widget.dart';
import '../widgets/challenge_widgets/challenge_drag_drop_widget.dart';
import '../widgets/challenge_widgets/interactive_scene_widget.dart';

class GameScreen extends StatefulWidget {
  final int worldId;
  final String levelId;

  const GameScreen({
    super.key,
    required this.worldId,
    required this.levelId,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GameBloc>().add(LoadLevelEvent(widget.worldId, widget.levelId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: SafeArea(
        child: BlocConsumer<GameBloc, GameState>(
          listener: (context, state) {
            if (state is LevelCompleted) {
              context.push('/level-complete', extra: state);
            }
            if (state is ChallengeHintDisplayed) {
              _showChallengeHintDialog(state);
            }
          },
          builder: (context, state) {
            if (state is GameLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading level...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is GameError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Back to Levels'),
                    ),
                  ],
                ),
              );
            }

            if (state is GameReady) {
              return _buildReadyScreen(state);
            }

            if (state is AnswerSubmitted) {
              return AnswerFeedback(
                isCorrect: state.isCorrect,
                correctAnswer: state.correctAnswer,
                explanation: state.explanation,
                onContinue: () {
                  context.read<GameBloc>().add(NextQuestionEvent());
                },
              );
            }

            if (state is HintDisplayed) {
              Future.microtask(() {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: Row(
                      children: [
                        const Icon(Icons.lightbulb, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text('Hint ${state.hint.level}'),
                      ],
                    ),
                    content: Text(
                      state.hint.text,
                      style: const TextStyle(fontSize: 18),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          context.read<GameBloc>().add(NextQuestionEvent());
                        },
                        child: const Text('Got it!'),
                      ),
                    ],
                  ),
                );
              });
            }

            if (state is QuestionActive || state is HintDisplayed) {
              final levelData = state is QuestionActive
                  ? state.levelData
                  : (state as HintDisplayed).levelData;
              final session = state is QuestionActive
                  ? state.session
                  : (state as HintDisplayed).session;
              final currentQuestion = state is QuestionActive
                  ? state.currentQuestion
                  : (state as HintDisplayed).currentQuestion;
              final questionIndex = state is QuestionActive
                  ? state.questionIndex
                  : (state as HintDisplayed).questionIndex;

              return Column(
                children: [
                  GameHeader(
                    currentQuestion: questionIndex + 1,
                    totalQuestions: levelData.totalQuestions,
                    score: session.score,
                    hintsRemaining: session.hintsRemaining,
                    onHintPressed: () {
                      context
                          .read<GameBloc>()
                          .add(RequestHintEvent(currentQuestion.id));
                    },
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: _buildQuestionWidget(
                        context,
                        currentQuestion,
                      ),
                    ),
                  ),
                ],
              );
            }

            // --- Challenge mode states ---

            if (state is ChallengeActive) {
              return Column(
                children: [
                  ChallengeHeader(
                    title: state.levelData.title,
                    progressPercent: state.session.completionPercent,
                    score: state.session.score,
                    hintsRemaining: state.session.hintsRemaining,
                    onHintPressed: () {
                      context
                          .read<GameBloc>()
                          .add(RequestChallengeHintEvent());
                    },
                    onBackPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: _buildChallengeWidget(
                      context,
                      state.levelData,
                    ),
                  ),
                ],
              );
            }

            if (state is ChallengeHintDisplayed) {
              // Re-render the challenge while hint dialog is shown
              return Column(
                children: [
                  ChallengeHeader(
                    title: state.levelData.title,
                    progressPercent: state.session.completionPercent,
                    score: state.session.score,
                    hintsRemaining: state.hintsRemaining,
                    onHintPressed: () {
                      context
                          .read<GameBloc>()
                          .add(RequestChallengeHintEvent());
                    },
                    onBackPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: _buildChallengeWidget(
                      context,
                      state.levelData,
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildReadyScreen(GameReady state) {
    final challenge = state.levelData.challenge;

    return Center(
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.levelData.title,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                state.levelData.description,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              // Story text (challenge mode)
              if (challenge?.storyText != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.purple.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_stories,
                          color: Colors.purple.shade400, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          challenge!.storyText!,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.purple.shade900,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Lesson content (challenge mode)
              if (challenge?.lessonContent != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.school,
                          color: Colors.blue.shade400, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          challenge!.lessonContent!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue.shade900,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (state.levelData.isChallengeMode) {
                    context.read<GameBloc>().add(StartChallengeEvent());
                  } else {
                    context.read<GameBloc>().add(NextQuestionEvent());
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Start!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChallengeHintDialog(ChallengeHintDisplayed state) {
    Future.microtask(() {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.orange),
              const SizedBox(width: 8),
              Text('Hint ${state.hintIndex + 1}'),
            ],
          ),
          content: Text(
            state.hintText,
            style: const TextStyle(fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Resume challenge
                context.read<GameBloc>().add(StartChallengeEvent());
              },
              child: const Text('Got it!'),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildChallengeWidget(BuildContext context, LevelData levelData) {
    final challenge = levelData.challenge!;
    final config = challenge.challengeConfig;

    void onComplete(Map<String, dynamic> results) {
      context.read<GameBloc>().add(CompleteChallengeEvent(results));
    }

    switch (challenge.challengeType) {
      case ChallengeType.tapObjects:
        return TapObjectsWidget(config: config, onComplete: onComplete);
      case ChallengeType.sortItems:
        return SortItemsWidget(config: config, onComplete: onComplete);
      case ChallengeType.pathFinding:
        return PathFindingWidget(config: config, onComplete: onComplete);
      case ChallengeType.puzzle:
        return PuzzleWidget(config: config, onComplete: onComplete);
      case ChallengeType.memoryGame:
        return MemoryGameWidget(config: config, onComplete: onComplete);
      case ChallengeType.matching:
        return MatchingWidget(config: config, onComplete: onComplete);
      case ChallengeType.sequencing:
        return SequencingWidget(config: config, onComplete: onComplete);
      case ChallengeType.multipleChoice:
        return ChallengeMultipleChoiceWidget(
            config: config, onComplete: onComplete);
      case ChallengeType.dragDrop:
        return ChallengeDragDropWidget(
            config: config, onComplete: onComplete);
      case ChallengeType.interactiveScene:
        return InteractiveSceneWidget(
            config: config, onComplete: onComplete);
    }
  }

  Widget _buildQuestionWidget(BuildContext context, Question question) {
    switch (question.type) {
      case QuestionType.multipleChoice:
      case QuestionType.wordProblem:
        return MultipleChoiceWidget(
          question: question,
          onAnswerSelected: (answer) {
            context
                .read<GameBloc>()
                .add(SubmitAnswerEvent(question.id, answer));
          },
        );

      case QuestionType.fillInBlank:
        return FillBlankWidget(
          question: question,
          onAnswerSubmitted: (answer) {
            context
                .read<GameBloc>()
                .add(SubmitAnswerEvent(question.id, answer));
          },
        );

      case QuestionType.dragAndDrop:
        return DragDropWidget(
          question: question,
          onAnswerSubmitted: (answer) {
            context
                .read<GameBloc>()
                .add(SubmitAnswerEvent(question.id, answer));
          },
        );
    }
  }
}
