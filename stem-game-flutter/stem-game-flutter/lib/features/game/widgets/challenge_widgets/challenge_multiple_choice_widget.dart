import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/services/game_sound_service.dart';

class ChallengeMultipleChoiceWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final Function(Map<String, dynamic>) onComplete;

  const ChallengeMultipleChoiceWidget({
    super.key,
    required this.config,
    required this.onComplete,
  });

  @override
  State<ChallengeMultipleChoiceWidget> createState() =>
      _ChallengeMultipleChoiceWidgetState();
}

class _ChallengeMultipleChoiceWidgetState
    extends State<ChallengeMultipleChoiceWidget> {
  late List<Map<String, dynamic>> _questions;
  int _currentIndex = 0;
  int _correctAnswers = 0;
  int? _selectedOption;
  bool _answered = false;
  String? _explanation;

  @override
  void initState() {
    super.initState();
    _questions = (widget.config['questions'] as List<dynamic>)
        .map((q) => q as Map<String, dynamic>)
        .toList();
  }

  void _selectOption(int index) {
    if (_answered) return;
    setState(() {
      _selectedOption = index;
      _answered = true;
      final correctAnswer = _questions[_currentIndex]['correctAnswer'] as int;
      if (index == correctAnswer) {
        _correctAnswers++;
        GameSoundService.playCorrect();
      } else {
        GameSoundService.playWrong();
      }
      _explanation = _questions[_currentIndex]['explanation'] as String?;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (_currentIndex + 1 >= _questions.length) {
      GameSoundService.playComplete();
      widget.onComplete({
        'correctAnswers': _correctAnswers,
        'totalQuestions': _questions.length,
      });
    } else {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _answered = false;
        _explanation = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentIndex];
    final questionText = q['question'] as String;
    final options = (q['options'] as List<dynamic>).cast<String>();
    final correctAnswer = q['correctAnswer'] as int;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_questions.length, (i) {
              return Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < _currentIndex
                      ? Colors.green
                      : i == _currentIndex
                          ? Colors.blue
                          : Colors.grey.shade300,
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          // Question card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              questionText,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),

          // Options grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: options.length <= 2 ? 1 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: options.length <= 2 ? 4.0 : 2.5,
            ),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedOption == index;
              final isCorrect = index == correctAnswer;
              Color bgColor = Colors.white;
              Color textColor = Colors.black87;
              Color borderColor = Colors.grey.shade300;

              if (_answered) {
                if (isCorrect) {
                  bgColor = Colors.green;
                  textColor = Colors.white;
                  borderColor = Colors.green;
                } else if (isSelected && !isCorrect) {
                  bgColor = Colors.red.shade400;
                  textColor = Colors.white;
                  borderColor = Colors.red;
                }
              } else if (isSelected) {
                bgColor = Colors.blue;
                textColor = Colors.white;
                borderColor = Colors.blue;
              }

              return GestureDetector(
                onTap: _answered
                    ? null
                    : () {
                        GameSoundService.playTap();
                        _selectOption(index);
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        options[index],
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Explanation
          if (_answered && _explanation != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _explanation!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2),
          ],
        ],
      ),
    );
  }
}
