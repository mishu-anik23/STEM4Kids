import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/challenge_icon_mapper.dart';
import '../../../../core/services/game_sound_service.dart';

class SortItemsWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final Function(Map<String, dynamic>) onComplete;

  const SortItemsWidget({
    super.key,
    required this.config,
    required this.onComplete,
  });

  @override
  State<SortItemsWidget> createState() => _SortItemsWidgetState();
}

class _SortItemsWidgetState extends State<SortItemsWidget> {
  late List<String> _category1Items;
  late List<String> _category2Items;
  late List<String> _categories;
  late List<String> _unsortedItems;
  final List<String> _bucket1 = [];
  final List<String> _bucket2 = [];
  int _correctPlacements = 0;
  int _totalItems = 0;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _categories =
        (widget.config['categories'] as List<dynamic>).cast<String>();

    // Get items from whichever keys are present
    final keys = widget.config.keys.toList();
    final itemKeys =
        keys.where((k) => k != 'categories' && widget.config[k] is List).toList();

    if (itemKeys.length >= 2) {
      _category1Items =
          (widget.config[itemKeys[0]] as List<dynamic>).cast<String>();
      _category2Items =
          (widget.config[itemKeys[1]] as List<dynamic>).cast<String>();
    } else {
      _category1Items = [];
      _category2Items = [];
    }

    _unsortedItems = [..._category1Items, ..._category2Items];
    _unsortedItems.shuffle(Random());
    _totalItems = _unsortedItems.length;
  }

  void _onItemDropped(String item, int bucketIndex) {
    if (_completed) return;

    final isCorrect = (bucketIndex == 0 && _category1Items.contains(item)) ||
        (bucketIndex == 1 && _category2Items.contains(item));

    setState(() {
      _unsortedItems.remove(item);
      if (bucketIndex == 0) {
        _bucket1.add(item);
      } else {
        _bucket2.add(item);
      }
      if (isCorrect) {
        _correctPlacements++;
        GameSoundService.playCorrect();
      } else {
        GameSoundService.playWrong();
      }
    });

    if (_unsortedItems.isEmpty) {
      setState(() => _completed = true);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        GameSoundService.playComplete();
        widget.onComplete({
          'correctPlacements': _correctPlacements,
          'totalItems': _totalItems,
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Bucket 1
          Expanded(child: _buildBucket(0, _categories[0], _bucket1,
              Colors.green.shade100, Colors.green)),
          // Unsorted items in center
          SizedBox(
            width: 160,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Drag each item\nto the right side',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  '${_unsortedItems.length} left',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: _unsortedItems.map((item) {
                        return Draggable<String>(
                          data: item,
                          onDragStarted: GameSoundService.playDrag,
                          feedback: Material(
                            color: Colors.transparent,
                            child: _buildItemCard(item, Colors.blue, Colors.white,
                                elevated: true),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child:
                                _buildItemCard(item, Colors.grey.shade200, Colors.grey),
                          ),
                          child:
                              _buildItemCard(item, Colors.white, Colors.black87),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bucket 2
          Expanded(child: _buildBucket(1, _categories[1], _bucket2,
              Colors.red.shade100, Colors.red)),
        ],
      ),
    );
  }

  Widget _buildBucket(int index, String label, List<String> items,
      Color bgColor, Color borderColor) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (_) => !_completed,
      onAcceptWithDetails: (details) {
        GameSoundService.playDrop();
        _onItemDropped(details.data, index);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isHovering ? bgColor.withValues(alpha: 0.8) : bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isHovering ? borderColor : borderColor.withValues(alpha: 0.5),
              width: isHovering ? 3 : 2,
            ),
            boxShadow: isHovering
                ? [
                    BoxShadow(
                      color: borderColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: items.map((item) {
                      final isCorrect =
                          (index == 0 && _category1Items.contains(item)) ||
                              (index == 1 && _category2Items.contains(item));
                      return _buildSortedItem(item, isCorrect);
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemCard(String name, Color bgColor, Color textColor,
      {bool elevated = false}) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade300, width: 2),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
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
            size: 28,
            color: textColor == Colors.white
                ? Colors.white
                : ChallengeIconMapper.getColor(name),
          ),
          const SizedBox(height: 2),
          Text(
            name[0].toUpperCase() + name.substring(1),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSortedItem(String name, bool isCorrect) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.red,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            ChallengeIconMapper.getIcon(name),
            size: 16,
            color: ChallengeIconMapper.getColor(name),
          ),
          const SizedBox(width: 4),
          Text(
            name[0].toUpperCase() + name.substring(1),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 4),
          Icon(
            isCorrect ? Icons.check : Icons.close,
            size: 14,
            color: isCorrect ? Colors.green : Colors.red,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.8, 0.8));
  }
}
