import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/challenge_icon_mapper.dart';
import '../../../../core/services/game_sound_service.dart';

class InteractiveSceneWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final Function(Map<String, dynamic>) onComplete;

  const InteractiveSceneWidget({
    super.key,
    required this.config,
    required this.onComplete,
  });

  @override
  State<InteractiveSceneWidget> createState() => _InteractiveSceneWidgetState();
}

class _InteractiveSceneWidgetState extends State<InteractiveSceneWidget> {
  bool get _isRoomVariant => widget.config.containsKey('rooms');

  @override
  Widget build(BuildContext context) {
    if (_isRoomVariant) {
      return _RoomVariant(
        config: widget.config,
        onComplete: widget.onComplete,
      );
    } else {
      return _SceneVariant(
        config: widget.config,
        onComplete: widget.onComplete,
      );
    }
  }
}

// --- Variant A: Room-based (Hide & Seek) ---
class _RoomVariant extends StatefulWidget {
  final Map<String, dynamic> config;
  final Function(Map<String, dynamic>) onComplete;

  const _RoomVariant({required this.config, required this.onComplete});

  @override
  State<_RoomVariant> createState() => _RoomVariantState();
}

class _RoomVariantState extends State<_RoomVariant> {
  late List<Map<String, dynamic>> _rooms;
  int _currentRoom = 0;
  int _objectivesCompleted = 0;
  String? _selectedLight;
  bool _lightChosen = false;
  bool _showingObjects = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _rooms = (widget.config['rooms'] as List<dynamic>)
        .map((r) => r as Map<String, dynamic>)
        .toList();
  }

  void _chooseLight(String light) {
    if (_lightChosen || _completed) return;
    final room = _rooms[_currentRoom];
    final correctLight = room['correctLight'] as String;
    final isCorrect = light == correctLight;

    setState(() {
      _selectedLight = light;
      _lightChosen = true;
    });

    if (isCorrect) {
      GameSoundService.playCorrect();
      _objectivesCompleted++;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        setState(() => _showingObjects = true);
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        _nextRoom();
      });
    } else {
      GameSoundService.playWrong();
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _selectedLight = null;
          _lightChosen = false;
        });
      });
    }
  }

  void _nextRoom() {
    if (_currentRoom + 1 >= _rooms.length) {
      setState(() => _completed = true);
      GameSoundService.playComplete();
      widget.onComplete({
        'objectivesCompleted': _objectivesCompleted,
        'totalObjectives': _rooms.length,
      });
    } else {
      setState(() {
        _currentRoom++;
        _selectedLight = null;
        _lightChosen = false;
        _showingObjects = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final room = _rooms[_currentRoom];
    final roomName = room['name'] as String;
    final availableLights =
        (room['availableLights'] as List<dynamic>).cast<String>();
    final hiddenObjects =
        (room['hiddenObjects'] as List<dynamic>).cast<String>();
    final correctLight = room['correctLight'] as String;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_rooms.length, (i) {
              return Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < _currentRoom
                      ? Colors.green
                      : i == _currentRoom
                          ? Colors.blue
                          : Colors.grey.shade300,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // Room scene
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: _showingObjects
                  ? Colors.amber.shade100
                  : Colors.grey.shade900,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _showingObjects ? Colors.amber : Colors.grey.shade600,
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                // Room name
                Positioned(
                  top: 12,
                  left: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      roomName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Hidden objects (revealed when correct light chosen)
                if (_showingObjects)
                  Center(
                    child: Wrap(
                      spacing: 24,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: hiddenObjects.map((obj) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              ChallengeIconMapper.getIcon(obj),
                              size: 40,
                              color: ChallengeIconMapper.getColor(obj),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              obj[0].toUpperCase() + obj.substring(1),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .scale(begin: const Offset(0.5, 0.5));
                      }).toList(),
                    ),
                  ),

                // Dark room message
                if (!_showingObjects && !_lightChosen)
                  const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.visibility_off,
                            size: 48, color: Colors.white38),
                        SizedBox(height: 8),
                        Text(
                          'Too dark! Choose the right light.',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white60,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Wrong choice flash
                if (_lightChosen &&
                    !_showingObjects &&
                    _selectedLight != correctLight)
                  Center(
                    child: const Icon(Icons.close, size: 64, color: Colors.red)
                        .animate()
                        .fadeIn(duration: 200.ms)
                        .shake(hz: 3),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Light choice buttons
          const Text(
            'Pick the best light:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: availableLights.map((light) {
              final isSelected = _selectedLight == light;
              final isCorrectSelected =
                  isSelected && light == correctLight && _lightChosen;
              final isWrongSelected =
                  isSelected && light != correctLight && _lightChosen;

              Color bgColor = Colors.white;
              Color borderColor = Colors.grey.shade300;
              if (isCorrectSelected) {
                bgColor = Colors.green.shade100;
                borderColor = Colors.green;
              } else if (isWrongSelected) {
                bgColor = Colors.red.shade100;
                borderColor = Colors.red;
              }

              return GestureDetector(
                onTap: () {
                  GameSoundService.playTap();
                  _chooseLight(light);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 120,
                  padding: const EdgeInsets.all(16),
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
                  child: Column(
                    children: [
                      Icon(
                        ChallengeIconMapper.getIcon(light),
                        size: 36,
                        color: ChallengeIconMapper.getColor(light),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        light.replaceAll('_', ' '),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// --- Variant B: Scene-based (Place lights in zones) ---
class _SceneVariant extends StatefulWidget {
  final Map<String, dynamic> config;
  final Function(Map<String, dynamic>) onComplete;

  const _SceneVariant({required this.config, required this.onComplete});

  @override
  State<_SceneVariant> createState() => _SceneVariantState();
}

class _SceneVariantState extends State<_SceneVariant> {
  late String _sceneName;
  late List<Map<String, dynamic>> _availableLights;
  late List<Map<String, dynamic>> _placementZones;
  final Map<String, String> _placements = {}; // zoneName -> lightType
  int _objectivesCompleted = 0;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _sceneName = widget.config['scene'] as String? ?? 'Scene';
    _availableLights =
        (widget.config['availableLights'] as List<dynamic>?)
                ?.map((l) => l as Map<String, dynamic>)
                .toList() ??
            [];
    _placementZones =
        (widget.config['placementZones'] as List<dynamic>?)
                ?.map((z) => z as Map<String, dynamic>)
                .toList() ??
            [];
  }

  void _placeLight(String zoneName, String lightType) {
    if (_completed) return;
    final zone =
        _placementZones.firstWhere((z) => z['name'] == zoneName);
    final requiredLight = zone['requiredLight'] as String;
    final isCorrect = lightType == requiredLight;

    setState(() {
      _placements[zoneName] = lightType;
      if (isCorrect) {
        _objectivesCompleted++;
        GameSoundService.playCorrect();
      } else {
        GameSoundService.playWrong();
      }
    });

    GameSoundService.playDrop();

    if (_placements.length >= _placementZones.length) {
      setState(() => _completed = true);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        GameSoundService.playComplete();
        widget.onComplete({
          'objectivesCompleted': _objectivesCompleted,
          'totalObjectives': _placementZones.length,
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
          // Placement zones
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Text(
                  _sceneName.replaceAll('_', ' ').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: _placementZones.length,
                    itemBuilder: (context, index) {
                      final zone = _placementZones[index];
                      final zoneName = zone['name'] as String;
                      final placedLight = _placements[zoneName];
                      final requiredLight = zone['requiredLight'] as String;
                      final isCorrect = placedLight == requiredLight;

                      return DragTarget<String>(
                        onWillAcceptWithDetails: (_) =>
                            !_completed && !_placements.containsKey(zoneName),
                        onAcceptWithDetails: (details) {
                          _placeLight(zoneName, details.data);
                        },
                        builder: (context, candidateData, rejectedData) {
                          final isHovering = candidateData.isNotEmpty;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: placedLight != null
                                  ? (isCorrect
                                      ? Colors.green.shade50
                                      : Colors.red.shade50)
                                  : (isHovering
                                      ? Colors.blue.shade50
                                      : Colors.grey.shade100),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: placedLight != null
                                    ? (isCorrect ? Colors.green : Colors.red)
                                    : (isHovering
                                        ? Colors.blue
                                        : Colors.grey.shade300),
                                width: isHovering ? 3 : 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.place,
                                  color: placedLight != null
                                      ? (isCorrect
                                          ? Colors.green
                                          : Colors.red)
                                      : Colors.grey,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        zoneName.replaceAll('_', ' '),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (placedLight != null)
                                        Text(
                                          placedLight.replaceAll('_', ' '),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isCorrect
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (placedLight != null)
                                  Icon(
                                    isCorrect
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color:
                                        isCorrect ? Colors.green : Colors.red,
                                    size: 28,
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Light inventory
          SizedBox(
            width: 130,
            child: Column(
              children: [
                const Text(
                  'Lights',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: _availableLights.length,
                    itemBuilder: (context, index) {
                      final light = _availableLights[index];
                      final type = light['type'] as String;
                      final quantity = light['quantity'] as int? ?? 1;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Draggable<String>(
                          data: type,
                          onDragStarted: GameSoundService.playDrag,
                          feedback: Material(
                            color: Colors.transparent,
                            child: Container(
                              width: 100,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    ChallengeIconMapper.getIcon(type),
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    type.replaceAll('_', ' '),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: Colors.grey.shade300),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  ChallengeIconMapper.getIcon(type),
                                  size: 28,
                                  color: ChallengeIconMapper.getColor(type),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  type.replaceAll('_', ' '),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  'x$quantity',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
