import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/services/game_sound_service.dart';

class MatchingWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final Function(Map<String, dynamic>) onComplete;

  const MatchingWidget({
    super.key,
    required this.config,
    required this.onComplete,
  });

  @override
  State<MatchingWidget> createState() => _MatchingWidgetState();
}

class _MatchingWidgetState extends State<MatchingWidget> {
  late List<Map<String, dynamic>> _scenarios;
  int _currentIndex = 0;
  int _correctChoices = 0;
  int? _selectedOption;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _scenarios = (widget.config['scenarios'] as List<dynamic>)
        .map((s) => s as Map<String, dynamic>)
        .toList();
  }

  void _selectOption(int index) {
    if (_answered) return;
    final correctAnswer = _scenarios[_currentIndex]['correctAnswer'] as int;

    setState(() {
      _selectedOption = index;
      _answered = true;
      if (index == correctAnswer) {
        _correctChoices++;
        GameSoundService.playCorrect();
      } else {
        GameSoundService.playWrong();
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      _nextScenario();
    });
  }

  void _nextScenario() {
    if (_currentIndex + 1 >= _scenarios.length) {
      GameSoundService.playComplete();
      widget.onComplete({
        'correctChoices': _correctChoices,
        'totalScenarios': _scenarios.length,
      });
    } else {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _answered = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scenario = _scenarios[_currentIndex];
    final situation = scenario['situation'] as String;
    final options = (scenario['options'] as List<dynamic>).cast<String>();
    final correctAnswer = scenario['correctAnswer'] as int;
    final reason = scenario['reason'] as String?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_scenarios.length, (i) {
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
          const SizedBox(height: 20),

          // Scenario card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade50, Colors.blue.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.purple.shade200, width: 2),
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
                const Icon(Icons.lightbulb_outline,
                    size: 36, color: Colors.purple),
                const SizedBox(height: 12),
                Text(
                  situation,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Options
          ...List.generate(options.length, (index) {
            final isSelected = _selectedOption == index;
            final isCorrect = index == correctAnswer;

            Color bgColor = Colors.white;
            Color borderColor = Colors.grey.shade300;
            Color textColor = Colors.black87;
            IconData? trailingIcon;

            if (_answered) {
              if (isCorrect) {
                bgColor = Colors.green.shade100;
                borderColor = Colors.green;
                textColor = Colors.green.shade900;
                trailingIcon = Icons.check_circle;
              } else if (isSelected && !isCorrect) {
                bgColor = Colors.red.shade100;
                borderColor = Colors.red;
                textColor = Colors.red.shade900;
                trailingIcon = Icons.cancel;
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: _answered
                    ? null
                    : () {
                        GameSoundService.playTap();
                        _selectOption(index);
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          options[index],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                      if (trailingIcon != null)
                        Icon(trailingIcon,
                            color: isCorrect ? Colors.green : Colors.red,
                            size: 28),
                    ],
                  ),
                ),
              ),
            );
          }),

          // Reason explanation
          if (_answered && reason != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome,
                      color: Colors.amber.shade700, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      reason,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.amber.shade900,
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
