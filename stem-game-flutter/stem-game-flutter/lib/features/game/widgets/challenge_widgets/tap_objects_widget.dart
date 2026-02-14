import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/challenge_icon_mapper.dart';
import '../../../../core/services/game_sound_service.dart';

class TapObjectsWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final Function(Map<String, dynamic>) onComplete;

  const TapObjectsWidget({
    super.key,
    required this.config,
    required this.onComplete,
  });

  @override
  State<TapObjectsWidget> createState() => _TapObjectsWidgetState();
}

class _TapObjectsWidgetState extends State<TapObjectsWidget> {
  late List<String> _targetObjects;
  late List<String> _distractorObjects;
  late List<String> _allObjects;
  final Set<String> _tappedCorrect = {};
  final Set<String> _tappedWrong = {};
  String? _lastTapped;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _targetObjects =
        (widget.config['targetObjects'] as List<dynamic>).cast<String>();
    _distractorObjects =
        (widget.config['distractorObjects'] as List<dynamic>).cast<String>();

    // Combine and shuffle
    _allObjects = [..._targetObjects, ..._distractorObjects];
    _allObjects.shuffle(Random());
  }

  void _onTap(String objectName) {
    if (_completed) return;
    if (_tappedCorrect.contains(objectName) ||
        _tappedWrong.contains(objectName)) {
      return;
    }

    setState(() {
      _lastTapped = objectName;
      if (_targetObjects.contains(objectName)) {
        _tappedCorrect.add(objectName);
        GameSoundService.playCorrect();
      } else {
        _tappedWrong.add(objectName);
        GameSoundService.playWrong();
      }
    });

    // Complete only when ALL targets are found
    if (_tappedCorrect.length >= _targetObjects.length) {
      setState(() => _completed = true);
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        GameSoundService.playComplete();
        widget.onComplete({
          'correctTaps': _tappedCorrect.length,
          'wrongTaps': _tappedWrong.length,
          'totalTargets': _targetObjects.length,
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Instruction
          Container(
            padding: const EdgeInsets.all(16),
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
              'Tap all the correct objects! (${_tappedCorrect.length}/${_targetObjects.length})',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),

          // Objects grid
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: _allObjects.map((name) {
              final isCorrectlyTapped = _tappedCorrect.contains(name);
              final isWronglyTapped = _tappedWrong.contains(name);
              final isTapped = isCorrectlyTapped || isWronglyTapped;

              Color bgColor = Colors.white;
              Color borderColor = Colors.grey.shade300;
              if (isCorrectlyTapped) {
                bgColor = Colors.green.shade100;
                borderColor = Colors.green;
              } else if (isWronglyTapped) {
                bgColor = Colors.red.shade100;
                borderColor = Colors.red;
              }

              Widget card = GestureDetector(
                onTap: isTapped || _completed ? null : () => _onTap(name),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 100,
                  height: 110,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        ChallengeIconMapper.getIcon(name),
                        size: 40,
                        color: isTapped
                            ? (isCorrectlyTapped
                                ? Colors.green
                                : Colors.red)
                            : ChallengeIconMapper.getColor(name),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        name[0].toUpperCase() + name.substring(1),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isTapped ? Colors.grey : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isCorrectlyTapped)
                        const Icon(Icons.check_circle,
                            size: 16, color: Colors.green),
                      if (isWronglyTapped)
                        const Icon(Icons.cancel, size: 16, color: Colors.red),
                    ],
                  ),
                ),
              );

              // Add shake animation for wrong taps
              if (_lastTapped == name && isWronglyTapped) {
                card = card
                    .animate(onComplete: (_) {})
                    .shake(duration: 400.ms, hz: 4);
              }
              // Add scale animation for correct taps
              if (_lastTapped == name && isCorrectlyTapped) {
                card = card
                    .animate(onComplete: (_) {})
                    .scale(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.1, 1.1),
                      duration: 200.ms,
                    )
                    .then()
                    .scale(
                      begin: const Offset(1.1, 1.1),
                      end: const Offset(1.0, 1.0),
                      duration: 200.ms,
                    );
              }

              return card;
            }).toList(),
          ),
        ],
      ),
    );
  }
}
