import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/challenge_icon_mapper.dart';
import '../../../../core/services/game_sound_service.dart';

class SequencingWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final Function(Map<String, dynamic>) onComplete;

  const SequencingWidget({
    super.key,
    required this.config,
    required this.onComplete,
  });

  @override
  State<SequencingWidget> createState() => _SequencingWidgetState();
}

class _SequencingWidgetState extends State<SequencingWidget> {
  late List<Map<String, dynamic>> _sequences;
  int _currentIndex = 0;
  int _correctSequences = 0;
  late List<String> _currentItems;
  bool _checked = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _sequences = (widget.config['sequences'] as List<dynamic>)
        .map((s) => s as Map<String, dynamic>)
        .toList();
    _loadSequence();
  }

  void _loadSequence() {
    final seq = _sequences[_currentIndex];
    final items = (seq['items'] as List<dynamic>).cast<String>();
    _currentItems = List.from(items);
    // Shuffle until different from correct order
    final correctOrder = (seq['correctOrder'] as List<dynamic>).cast<int>();
    do {
      _currentItems.shuffle(Random());
    } while (_currentItems.length > 1 &&
        _isOrderCorrect(_currentItems, items, correctOrder));
    _checked = false;
    _isCorrect = false;
  }

  bool _isOrderCorrect(
      List<String> current, List<String> original, List<int> correctOrder) {
    for (int i = 0; i < correctOrder.length; i++) {
      if (current[i] != original[correctOrder[i]]) return false;
    }
    return true;
  }

  void _checkOrder() {
    final seq = _sequences[_currentIndex];
    final items = (seq['items'] as List<dynamic>).cast<String>();
    final correctOrder = (seq['correctOrder'] as List<dynamic>).cast<int>();

    final isCorrect = _isOrderCorrect(_currentItems, items, correctOrder);

    setState(() {
      _checked = true;
      _isCorrect = isCorrect;
      if (isCorrect) {
        _correctSequences++;
        GameSoundService.playCorrect();
      } else {
        GameSoundService.playWrong();
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      _nextSequence();
    });
  }

  void _nextSequence() {
    if (_currentIndex + 1 >= _sequences.length) {
      GameSoundService.playComplete();
      widget.onComplete({
        'correctSequences': _correctSequences,
        'totalSequences': _sequences.length,
      });
    } else {
      setState(() {
        _currentIndex++;
        _loadSequence();
      });
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (_checked) return;
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _currentItems.removeAt(oldIndex);
      _currentItems.insert(newIndex, item);
    });
    GameSoundService.playDrop();
  }

  @override
  Widget build(BuildContext context) {
    final seq = _sequences[_currentIndex];
    final description = seq['description'] as String? ?? 'Put them in order';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_sequences.length, (i) {
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

          // Instruction card
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.swap_vert, size: 28, color: Colors.blue),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Arrow indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.arrow_forward, size: 18, color: Colors.blue.shade700),
                    const SizedBox(width: 4),
                    Text(
                      'Drag to reorder',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Reorderable items
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _currentItems.length,
            onReorder: _onReorder,
            proxyDecorator: (child, index, animation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(16),
                    child: child,
                  );
                },
                child: child,
              );
            },
            itemBuilder: (context, index) {
              final item = _currentItems[index];
              Color bgColor = Colors.white;
              Color borderColor = Colors.grey.shade300;

              if (_checked) {
                if (_isCorrect) {
                  bgColor = Colors.green.shade100;
                  borderColor = Colors.green;
                } else {
                  bgColor = Colors.red.shade50;
                  borderColor = Colors.red.shade300;
                }
              }

              return Container(
                key: ValueKey('$item-$index'),
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      ChallengeIconMapper.getIcon(item),
                      size: 32,
                      color: ChallengeIconMapper.getColor(item),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item[0].toUpperCase() + item.substring(1),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (!_checked)
                      Icon(Icons.drag_handle,
                          color: Colors.grey.shade400, size: 28),
                    if (_checked && _isCorrect)
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 28),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Check button
          if (!_checked)
            Center(
              child: ElevatedButton.icon(
                onPressed: _checkOrder,
                icon: const Icon(Icons.check, size: 24),
                label: const Text(
                  'Check Order',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

          // Result message
          if (_checked)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isCorrect ? Colors.green.shade100 : Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isCorrect ? Colors.green : Colors.red,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isCorrect ? Icons.celebration : Icons.refresh,
                    color: _isCorrect ? Colors.green : Colors.red,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isCorrect ? 'Perfect order!' : 'Not quite right...',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _isCorrect
                          ? Colors.green.shade900
                          : Colors.red.shade900,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9)),
        ],
      ),
    );
  }
}
