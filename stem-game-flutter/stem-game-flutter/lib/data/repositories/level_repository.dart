import 'dart:convert';
import 'package:flutter/services.dart';
import '../../features/game/models/level_data.dart';

class LevelRepository {
  Future<LevelData> loadLevel(int worldId, int levelId) async {
    try {
      final levelFileName = 'level_${levelId.toString().padLeft(2, '0')}.json';
      final jsonString = await rootBundle.loadString(
        'assets/data/levels/world_$worldId/$levelFileName',
      );

      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      return LevelData.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to load level $levelId from world $worldId: $e');
    }
  }

  Future<List<LevelData>> loadAllWorldLevels(int worldId, {int count = 20}) async {
    final levels = <LevelData>[];

    for (int levelId = 1; levelId <= count; levelId++) {
      try {
        final level = await loadLevel(worldId, levelId);
        levels.add(level);
      } catch (e) {
        print('Warning: Could not load level $levelId for world $worldId: $e');
      }
    }

    return levels;
  }
}
