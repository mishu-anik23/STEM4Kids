import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/game_state.dart';
import '../../../core/utils/score_calculator.dart';
import '../../progress/bloc/progress_bloc.dart';

class LevelCompleteScreen extends StatefulWidget {
  final LevelCompleted levelCompleted;

  const LevelCompleteScreen({
    super.key,
    required this.levelCompleted,
  });

  @override
  State<LevelCompleteScreen> createState() => _LevelCompleteScreenState();
}

class _LevelCompleteScreenState extends State<LevelCompleteScreen>
    with TickerProviderStateMixin {
  late AnimationController _starsController;
  late AnimationController _scoreController;
  late Animation<double> _starsAnimation;
  late Animation<int> _scoreAnimation;
  bool _submittedToBackend = false;

  @override
  void initState() {
    super.initState();

    _starsController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _starsAnimation = CurvedAnimation(
      parent: _starsController,
      curve: Curves.elasticOut,
    );

    _scoreAnimation = IntTween(
      begin: 0,
      end: widget.levelCompleted.finalScore,
    ).animate(CurvedAnimation(
      parent: _scoreController,
      curve: Curves.easeOut,
    ));

    _starsController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _scoreController.forward();
      }
    });

    // Submit to backend
    _submitLevelCompletion();
  }

  void _submitLevelCompletion() {
    if (_submittedToBackend) return;
    _submittedToBackend = true;

    context.read<ProgressBloc>().add(
          SubmitLevelCompletionEvent(
            worldId: widget.levelCompleted.worldId,
            levelId: widget.levelCompleted.levelId,
            score: widget.levelCompleted.finalScore,
            timeSpentSeconds: widget.levelCompleted.timeSpent,
            hintsUsed: widget.levelCompleted.hintsUsed,
          ),
        );
  }

  @override
  void dispose() {
    _starsController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stars = widget.levelCompleted.stars;
    final message = ScoreCalculator.getStarMessage(stars);

    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Level Complete!',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              ScaleTransition(
                scale: _starsAnimation,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final isEarned = index < stars;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        isEarned ? Icons.star : Icons.star_border,
                        size: 80,
                        color: isEarned ? Colors.amber : Colors.grey.shade300,
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildStatRow(
                      'Score',
                      AnimatedBuilder(
                        animation: _scoreAnimation,
                        builder: (context, child) {
                          return Text(
                            '${_scoreAnimation.value}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 32),
                    _buildStatRow(
                      'Coins Earned',
                      Text(
                        '${widget.levelCompleted.coinsEarned}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                    const Divider(height: 32),
                    _buildStatRow(
                      'Time',
                      Text(
                        '${widget.levelCompleted.timeSpent}s',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (widget.levelCompleted.hintsUsed > 0) ...[
                      const Divider(height: 32),
                      _buildStatRow(
                        'Hints Used',
                        Text(
                          '${widget.levelCompleted.hintsUsed}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.go('/world/${widget.levelCompleted.worldId}');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.blue, width: 2),
                        ),
                      ),
                      child: const Text(
                        'Back to Levels',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final nextLevelId = widget.levelCompleted.levelId + 1;
                        if (nextLevelId <= 20) {
                          context.go(
                            '/game/${widget.levelCompleted.worldId}/$nextLevelId',
                          );
                        } else {
                          context.go('/world-map');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        widget.levelCompleted.levelId < 20
                            ? 'Next Level'
                            : 'World Map',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, Widget value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        value,
      ],
    );
  }
}
