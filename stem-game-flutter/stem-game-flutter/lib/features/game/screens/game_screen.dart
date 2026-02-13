import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../models/level_data.dart';
import '../widgets/game_header.dart';
import '../widgets/answer_feedback.dart';
import '../widgets/question_widgets/multiple_choice_widget.dart';
import '../widgets/question_widgets/fill_blank_widget.dart';
import '../widgets/question_widgets/drag_drop_widget.dart';

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
    // Load level when screen initializes
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
              context.go('/level-complete', extra: state);
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
              return Center(
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
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () {
                          context.read<GameBloc>().add(NextQuestionEvent());
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
              );
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

            return const SizedBox.shrink();
          },
        ),
      ),
    );
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
