import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/challenge_icon_mapper.dart';
import '../../../../core/services/game_sound_service.dart';

class PathFindingWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final Function(Map<String, dynamic>) onComplete;

  const PathFindingWidget({
    super.key,
    required this.config,
    required this.onComplete,
  });

  @override
  State<PathFindingWidget> createState() => _PathFindingWidgetState();
}

class _PathFindingWidgetState extends State<PathFindingWidget> {
  late int _rows;
  late int _cols;
  late List<String> _lightSourceTiles;
  late int _startRow, _startCol;
  late int _endRow, _endCol;
  late List<List<String?>> _grid;
  late int _currentRow, _currentCol;
  final List<List<int>> _path = [];
  int _wrongSteps = 0;
  bool _completed = false;
  String? _lastWrongCell;

  @override
  void initState() {
    super.initState();
    final gridSize = widget.config['gridSize'] as Map<String, dynamic>;
    _rows = gridSize['rows'] as int;
    _cols = gridSize['cols'] as int;
    _lightSourceTiles =
        (widget.config['lightSourceTiles'] as List<dynamic>).cast<String>();

    final startPos = widget.config['startPosition'] as Map<String, dynamic>;
    _startRow = startPos['row'] as int;
    _startCol = startPos['col'] as int;

    final endPos = widget.config['endPosition'] as Map<String, dynamic>;
    _endRow = endPos['row'] as int;
    _endCol = endPos['col'] as int;

    _currentRow = _startRow;
    _currentCol = _startCol;
    _path.add([_startRow, _startCol]);

    _generateGrid();
  }

  void _generateGrid() {
    final rand = Random(42); // Fixed seed for consistent layout
    _grid = List.generate(_rows, (_) => List.filled(_cols, null));

    // Place start and end
    _grid[_startRow][_startCol] = _lightSourceTiles[0];
    _grid[_endRow][_endCol] = 'goal';

    // Ensure a valid path exists by placing light sources along a path
    int r = _startRow, c = _startCol;
    while (r != _endRow || c != _endCol) {
      if (r < _endRow) {
        r++;
      } else if (c < _endCol) {
        c++;
      }
      if (r == _endRow && c == _endCol) break;
      _grid[r][c] = _lightSourceTiles[rand.nextInt(_lightSourceTiles.length)];
    }

    // Fill remaining cells with mix of light sources and empty cells
    for (int i = 0; i < _rows; i++) {
      for (int j = 0; j < _cols; j++) {
        if (_grid[i][j] == null) {
          if (rand.nextDouble() < 0.4) {
            _grid[i][j] =
                _lightSourceTiles[rand.nextInt(_lightSourceTiles.length)];
          }
          // null = dark/empty tile
        }
      }
    }
  }

  bool _isAdjacent(int row, int col) {
    final dr = (row - _currentRow).abs();
    final dc = (col - _currentCol).abs();
    return (dr + dc) == 1; // Only cardinal directions
  }

  void _onTileTap(int row, int col) {
    if (_completed) return;
    if (!_isAdjacent(row, col)) return;
    if (row == _currentRow && col == _currentCol) return;

    final tile = _grid[row][col];
    final isGoal = row == _endRow && col == _endCol;
    final isLightSource = tile != null && _lightSourceTiles.contains(tile);

    if (isGoal || isLightSource) {
      setState(() {
        _currentRow = row;
        _currentCol = col;
        _path.add([row, col]);
        _lastWrongCell = null;
      });
      GameSoundService.playTap();

      if (isGoal) {
        setState(() => _completed = true);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          GameSoundService.playComplete();
          widget.onComplete({
            'reachedEnd': true,
            'wrongSteps': _wrongSteps,
            'totalSteps': _path.length,
          });
        });
      }
    } else {
      // Wrong tile
      setState(() {
        _wrongSteps++;
        _lastWrongCell = '$row,$col';
      });
      GameSoundService.playWrong();
    }
  }

  @override
  Widget build(BuildContext context) {
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
            child: const Text(
              'Step only on light sources to reach the star!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),

          // Grid
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: _cols / _rows,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _cols,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: _rows * _cols,
                  itemBuilder: (context, index) {
                    final row = index ~/ _cols;
                    final col = index % _cols;
                    return _buildTile(row, col);
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(Colors.green.shade300, 'Start'),
              const SizedBox(width: 16),
              _buildLegendItem(Colors.amber.shade400, 'Goal'),
              const SizedBox(width: 16),
              _buildLegendItem(Colors.blue.shade100, 'Path'),
              const SizedBox(width: 16),
              _buildLegendItem(Colors.grey.shade400, 'Dark'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTile(int row, int col) {
    final tile = _grid[row][col];
    final isStart = row == _startRow && col == _startCol;
    final isEnd = row == _endRow && col == _endCol;
    final isCurrent = row == _currentRow && col == _currentCol;
    final isOnPath = _path.any((p) => p[0] == row && p[1] == col);
    final isAdjacent = _isAdjacent(row, col);
    final isWrong = _lastWrongCell == '$row,$col';
    final isLightSource = tile != null && _lightSourceTiles.contains(tile);

    Color bgColor;
    Color borderColor = Colors.transparent;
    double borderWidth = 0;

    if (isStart) {
      bgColor = Colors.green.shade300;
    } else if (isEnd) {
      bgColor = Colors.amber.shade300;
    } else if (isOnPath) {
      bgColor = Colors.blue.shade100;
    } else if (isLightSource) {
      bgColor = Colors.yellow.shade100;
    } else {
      bgColor = Colors.grey.shade700;
    }

    if (isCurrent && !_completed) {
      borderColor = Colors.blue;
      borderWidth = 3;
    } else if (isAdjacent && !_completed && !isOnPath) {
      borderColor = Colors.blue.withValues(alpha: 0.4);
      borderWidth = 2;
    }

    Widget content;
    if (isEnd) {
      content = const Icon(Icons.star, color: Colors.amber, size: 28);
    } else if (isCurrent) {
      content = const Icon(Icons.person, color: Colors.blue, size: 28);
    } else if (isOnPath) {
      content = Icon(Icons.circle, color: Colors.blue.shade300, size: 12);
    } else if (isLightSource) {
      content = Icon(
        ChallengeIconMapper.getIcon(tile),
        color: ChallengeIconMapper.getColor(tile),
        size: 24,
      );
    } else {
      content = const SizedBox.shrink();
    }

    Widget tileWidget = GestureDetector(
      onTap: () => _onTileTap(row, col),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: borderWidth > 0
              ? Border.all(color: borderColor, width: borderWidth)
              : null,
        ),
        child: Center(child: content),
      ),
    );

    if (isWrong) {
      tileWidget = tileWidget
          .animate(onComplete: (_) => setState(() => _lastWrongCell = null))
          .tint(color: Colors.red.withValues(alpha: 0.5), duration: 400.ms);
    }

    return tileWidget;
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
