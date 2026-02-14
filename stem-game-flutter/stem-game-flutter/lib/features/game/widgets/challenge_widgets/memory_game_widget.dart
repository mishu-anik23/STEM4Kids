import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/challenge_icon_mapper.dart';
import '../../../../core/services/game_sound_service.dart';

class MemoryGameWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final Function(Map<String, dynamic>) onComplete;

  const MemoryGameWidget({
    super.key,
    required this.config,
    required this.onComplete,
  });

  @override
  State<MemoryGameWidget> createState() => _MemoryGameWidgetState();
}

class _MemoryCard {
  final int id;
  final String content;
  final bool isImage;
  final int pairId;
  bool isFlipped = false;
  bool isMatched = false;

  _MemoryCard({
    required this.id,
    required this.content,
    required this.isImage,
    required this.pairId,
  });
}

class _MemoryGameWidgetState extends State<MemoryGameWidget> {
  late List<_MemoryCard> _cards;
  late int _crossAxisCount;
  int? _firstFlippedIndex;
  int _moves = 0;
  int _pairsMatched = 0;
  int _totalPairs = 0;
  bool _isProcessing = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    final pairs = (widget.config['pairs'] as List<dynamic>)
        .map((p) => p as Map<String, dynamic>)
        .toList();
    _totalPairs = pairs.length;

    // Parse grid size
    final gridSize = widget.config['gridSize'] as String? ?? '4x3';
    final parts = gridSize.split('x');
    _crossAxisCount = int.tryParse(parts[0]) ?? 4;

    // Create card pairs (image card + text card for each pair)
    _cards = [];
    for (int i = 0; i < pairs.length; i++) {
      _cards.add(_MemoryCard(
        id: i * 2,
        content: pairs[i]['image'] as String,
        isImage: true,
        pairId: i,
      ));
      _cards.add(_MemoryCard(
        id: i * 2 + 1,
        content: pairs[i]['text'] as String,
        isImage: false,
        pairId: i,
      ));
    }
    _cards.shuffle(Random());
  }

  void _onCardTap(int index) {
    if (_isProcessing || _completed) return;
    if (_cards[index].isFlipped || _cards[index].isMatched) return;

    setState(() {
      _cards[index].isFlipped = true;
      GameSoundService.playFlip();
    });

    if (_firstFlippedIndex == null) {
      _firstFlippedIndex = index;
    } else {

      _moves++;
      _isProcessing = true;

      // Check for match
      final first = _cards[_firstFlippedIndex!];
      final second = _cards[index];

      if (first.pairId == second.pairId) {
        // Match found
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          setState(() {
            first.isMatched = true;
            second.isMatched = true;
            _pairsMatched++;
            _firstFlippedIndex = null;

            _isProcessing = false;
          });
          GameSoundService.playMatch();

          if (_pairsMatched >= _totalPairs) {
            _completed = true;
            Future.delayed(const Duration(milliseconds: 600), () {
              if (!mounted) return;
              GameSoundService.playComplete();
              widget.onComplete({
                'pairsMatched': _pairsMatched,
                'totalPairs': _totalPairs,
                'moves': _moves,
              });
            });
          }
        });
      } else {
        // No match - flip back
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (!mounted) return;
          setState(() {
            first.isFlipped = false;
            second.isFlipped = false;
            _firstFlippedIndex = null;

            _isProcessing = false;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatChip(
                  Icons.touch_app, 'Moves: $_moves', Colors.blue),
              const SizedBox(width: 16),
              _buildStatChip(Icons.check_circle,
                  'Matched: $_pairsMatched/$_totalPairs', Colors.green),
            ],
          ),
          const SizedBox(height: 16),

          // Card grid
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _crossAxisCount,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.0,
              ),
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                return _buildCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(int index) {
    final card = _cards[index];
    final isRevealed = card.isFlipped || card.isMatched;

    Widget cardFace;
    if (isRevealed) {
      if (card.isImage) {
        cardFace = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              ChallengeIconMapper.getIcon(card.content),
              size: 36,
              color: ChallengeIconMapper.getColor(card.content),
            ),
            const SizedBox(height: 4),
            Text(
              card.content[0].toUpperCase() + card.content.substring(1),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      } else {
        cardFace = Center(
          child: Text(
            card.content,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        );
      }
    } else {
      cardFace = const Icon(
        Icons.question_mark,
        size: 36,
        color: Colors.white,
      );
    }

    Color bgColor;
    Color borderColor;
    if (card.isMatched) {
      bgColor = Colors.green.shade100;
      borderColor = Colors.green;
    } else if (isRevealed) {
      bgColor = Colors.white;
      borderColor = Colors.blue;
    } else {
      bgColor = Colors.blue.shade400;
      borderColor = Colors.blue.shade600;
    }

    Widget cardWidget = GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: cardFace,
      ),
    );

    if (card.isMatched) {
      cardWidget = cardWidget
          .animate(onComplete: (_) {})
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.05, 1.05),
            duration: 200.ms,
          )
          .then()
          .scale(
            begin: const Offset(1.05, 1.05),
            end: const Offset(1.0, 1.0),
            duration: 200.ms,
          );
    }

    return cardWidget;
  }
}
