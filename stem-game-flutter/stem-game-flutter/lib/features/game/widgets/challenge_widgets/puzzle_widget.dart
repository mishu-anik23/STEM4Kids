import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/services/game_sound_service.dart';

class PuzzleWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final Function(Map<String, dynamic>) onComplete;

  const PuzzleWidget({
    super.key,
    required this.config,
    required this.onComplete,
  });

  @override
  State<PuzzleWidget> createState() => _PuzzleWidgetState();
}

class _PuzzleWidgetState extends State<PuzzleWidget> {
  late int _roomWidth;
  late int _roomHeight;
  late List<Map<String, dynamic>> _lamps;
  late double _targetCoverage;
  late Set<String> _activeLamps;
  late List<List<bool>> _illuminated;
  double _currentCoverage = 0;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    final room = widget.config['room'] as Map<String, dynamic>;
    _roomWidth = room['width'] as int;
    _roomHeight = room['height'] as int;
    _lamps = (widget.config['lamps'] as List<dynamic>)
        .map((l) => l as Map<String, dynamic>)
        .toList();
    _targetCoverage =
        (widget.config['targetCoverage'] as num?)?.toDouble() ?? 0.9;
    _activeLamps = {};
    _illuminated =
        List.generate(_roomHeight, (_) => List.filled(_roomWidth, false));
    _updateIllumination();
  }

  void _toggleLamp(String lampId) {
    if (_completed) return;
    setState(() {
      if (_activeLamps.contains(lampId)) {
        _activeLamps.remove(lampId);
      } else {
        _activeLamps.add(lampId);
      }
      _updateIllumination();
    });
    GameSoundService.playTap();

    if (_currentCoverage >= _targetCoverage) {
      setState(() => _completed = true);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        GameSoundService.playComplete();
        widget.onComplete({
          'coverageAchieved': _currentCoverage,
          'targetCoverage': _targetCoverage,
          'lampsUsed': _activeLamps.length,
        });
      });
    }
  }

  void _updateIllumination() {
    // Reset
    for (int y = 0; y < _roomHeight; y++) {
      for (int x = 0; x < _roomWidth; x++) {
        _illuminated[y][x] = false;
      }
    }

    // Apply each active lamp's radius
    for (final lamp in _lamps) {
      if (!_activeLamps.contains(lamp['id'])) continue;
      final pos = lamp['position'] as Map<String, dynamic>;
      final lx = (pos['x'] as num).toInt();
      final ly = (pos['y'] as num).toInt();
      final radius = (lamp['radius'] as num).toInt();

      for (int y = 0; y < _roomHeight; y++) {
        for (int x = 0; x < _roomWidth; x++) {
          final dist = sqrt(pow(x - lx, 2) + pow(y - ly, 2));
          if (dist <= radius) {
            _illuminated[y][x] = true;
          }
        }
      }
    }

    // Calculate coverage
    int litCells = 0;
    final totalCells = _roomWidth * _roomHeight;
    for (int y = 0; y < _roomHeight; y++) {
      for (int x = 0; x < _roomWidth; x++) {
        if (_illuminated[y][x]) litCells++;
      }
    }
    _currentCoverage = totalCells > 0 ? litCells / totalCells : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Room grid
          Expanded(
            flex: 3,
            child: Column(
              children: [
                const Text(
                  'Turn on lamps to light up the room!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: _roomWidth / _roomHeight,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _roomWidth,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 2,
                        ),
                        itemCount: _roomWidth * _roomHeight,
                        itemBuilder: (context, index) {
                          final x = index % _roomWidth;
                          final y = index ~/ _roomWidth;
                          return _buildCell(x, y);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Lamp controls + coverage
          SizedBox(
            width: 160,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Coverage meter
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
                  child: Column(
                    children: [
                      const Text(
                        'Coverage',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: CircularProgressIndicator(
                              value: _currentCoverage,
                              strokeWidth: 8,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _currentCoverage >= _targetCoverage
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ),
                          Text(
                            '${(_currentCoverage * 100).round()}%',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Target: ${(_targetCoverage * 100).round()}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Lamp toggles
                const Text(
                  'Lamps',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(_lamps.length, (index) {
                  final lamp = _lamps[index];
                  final lampId = lamp['id'] as String;
                  final isActive = _activeLamps.contains(lampId);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () => _toggleLamp(lampId),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color:
                              isActive ? Colors.amber.shade100 : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isActive
                                ? Colors.amber
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isActive
                                  ? Icons.lightbulb
                                  : Icons.lightbulb_outline,
                              color: isActive
                                  ? Colors.amber.shade700
                                  : Colors.grey,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Lamp ${index + 1}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isActive
                                      ? Colors.amber.shade900
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(int x, int y) {
    final isLit = _illuminated[y][x];

    // Check if a lamp is at this position
    Map<String, dynamic>? lampHere;
    for (final lamp in _lamps) {
      final pos = lamp['position'] as Map<String, dynamic>;
      if ((pos['x'] as num).toInt() == x && (pos['y'] as num).toInt() == y) {
        lampHere = lamp;
        break;
      }
    }

    final isLampActive =
        lampHere != null && _activeLamps.contains(lampHere['id']);

    Color bgColor;
    if (isLit) {
      bgColor = Colors.yellow.shade200;
    } else {
      bgColor = Colors.grey.shade800;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: lampHere != null
            ? Border.all(
                color: isLampActive ? Colors.amber : Colors.grey,
                width: 2,
              )
            : null,
      ),
      child: lampHere != null
          ? Center(
              child: Icon(
                isLampActive ? Icons.lightbulb : Icons.lightbulb_outline,
                size: 16,
                color: isLampActive ? Colors.amber.shade700 : Colors.grey,
              ),
            )
          : null,
    );
  }
}
