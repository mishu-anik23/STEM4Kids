import 'package:flutter/material.dart';
import '../../../../core/utils/challenge_icon_mapper.dart';
import '../../../../core/services/game_sound_service.dart';

class ChallengeDragDropWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final Function(Map<String, dynamic>) onComplete;

  const ChallengeDragDropWidget({
    super.key,
    required this.config,
    required this.onComplete,
  });

  @override
  State<ChallengeDragDropWidget> createState() =>
      _ChallengeDragDropWidgetState();
}

class _ChallengeDragDropWidgetState extends State<ChallengeDragDropWidget> {
  late List<Map<String, dynamic>> _items;
  late List<Map<String, dynamic>> _zones;
  late String _instructions;
  final Map<String, String> _placements = {}; // zoneId -> itemId
  final Set<String> _placedItems = {};
  int _correctPlacements = 0;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _items = (widget.config['items'] as List<dynamic>?)
            ?.map((i) => i as Map<String, dynamic>)
            .toList() ??
        [];
    _zones = (widget.config['zones'] as List<dynamic>?)
            ?.map((z) => z as Map<String, dynamic>)
            .toList() ??
        [];
    _instructions =
        widget.config['instructions'] as String? ?? 'Drag items to the right zones';

    // If config doesn't have items/zones structure, create a fallback
    if (_items.isEmpty || _zones.isEmpty) {
      _buildFallbackFromConfig();
    }
  }

  void _buildFallbackFromConfig() {
    // Try to adapt other config formats into items/zones
    final keys = widget.config.keys.toList();
    final listKeys =
        keys.where((k) => widget.config[k] is List && k != 'categories').toList();

    if (listKeys.length >= 2) {
      final category1 =
          (widget.config[listKeys[0]] as List<dynamic>).cast<String>();
      final category2 =
          (widget.config[listKeys[1]] as List<dynamic>).cast<String>();
      final categories =
          (widget.config['categories'] as List<dynamic>?)?.cast<String>() ??
              ['Group A', 'Group B'];

      _zones = [
        {'id': 'zone_0', 'label': categories[0], 'acceptsItems': category1},
        {'id': 'zone_1', 'label': categories[1], 'acceptsItems': category2},
      ];
      _items = [...category1, ...category2]
          .map((name) => {'id': name, 'label': name, 'icon': name})
          .toList();
      _items.shuffle();
    }
  }

  void _onItemDroppedOnZone(String itemId, String zoneId) {
    if (_completed || _placedItems.contains(itemId)) return;

    final zone = _zones.firstWhere((z) => z['id'] == zoneId);
    final acceptsItems =
        (zone['acceptsItems'] as List<dynamic>).cast<String>();
    final isCorrect = acceptsItems.contains(itemId);

    setState(() {
      _placements[zoneId] = itemId;
      _placedItems.add(itemId);
      if (isCorrect) {
        _correctPlacements++;
        GameSoundService.playCorrect();
      } else {
        GameSoundService.playWrong();
      }
    });

    GameSoundService.playDrop();

    if (_placedItems.length >= _items.length) {
      setState(() => _completed = true);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        GameSoundService.playComplete();
        widget.onComplete({
          'correctPlacements': _correctPlacements,
          'totalItems': _items.length,
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final unplacedItems =
        _items.where((i) => !_placedItems.contains(i['id'])).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Instruction
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              _instructions,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),

          // Drop zones
          Expanded(
            child: Row(
              children: _zones.map((zone) {
                final zoneId = zone['id'] as String;
                final label = zone['label'] as String;
                final placedHere = _placements.entries
                    .where((e) => e.key == zoneId)
                    .map((e) => e.value)
                    .toList();

                return Expanded(
                  child: DragTarget<String>(
                    onWillAcceptWithDetails: (_) => !_completed,
                    onAcceptWithDetails: (details) {
                      _onItemDroppedOnZone(details.data, zoneId);
                    },
                    builder: (context, candidateData, rejectedData) {
                      final isHovering = candidateData.isNotEmpty;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isHovering
                              ? Colors.blue.shade50
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isHovering
                                ? Colors.blue
                                : Colors.grey.shade300,
                            width: isHovering ? 3 : 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                label,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: placedHere.map((itemId) {
                                    return Chip(
                                      label: Text(
                                        itemId,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      avatar: Icon(
                                        ChallengeIconMapper.getIcon(itemId),
                                        size: 16,
                                        color: ChallengeIconMapper.getColor(
                                            itemId),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Draggable items
          SizedBox(
            height: 90,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: unplacedItems.map((item) {
                  final itemId = item['id'] as String;
                  final label = item['label'] as String? ?? itemId;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Draggable<String>(
                      data: itemId,
                      onDragStarted: GameSoundService.playDrag,
                      feedback: Material(
                        color: Colors.transparent,
                        child: _buildItemCard(label, Colors.blue, Colors.white,
                            elevated: true),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: _buildItemCard(
                            label, Colors.grey.shade200, Colors.grey),
                      ),
                      child:
                          _buildItemCard(label, Colors.white, Colors.black87),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: elevated ? 0.2 : 0.1),
            blurRadius: elevated ? 8 : 4,
            offset: Offset(0, elevated ? 4 : 2),
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
            name.length > 8
                ? '${name.substring(0, 8)}..'
                : name[0].toUpperCase() + name.substring(1),
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
}
