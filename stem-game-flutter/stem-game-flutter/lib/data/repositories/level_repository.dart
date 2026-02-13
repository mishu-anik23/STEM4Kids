import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../features/game/models/level_data.dart';

class LevelRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<LevelData> loadLevel(int worldId, String levelId) async {
    try {
      // Try to fetch from API first (for new UUID-based levels)
      final response = await http.get(
        Uri.parse('$baseUrl/levels/$levelId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final levelDetails = data['data'] as Map<String, dynamic>;
          return LevelData.fromJson(levelDetails);
        }
      }

      // Fallback to local JSON files for old integer-based levels
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
        final level = await loadLevel(worldId, levelId.toString());
        levels.add(level);
      } catch (e) {
        print('Warning: Could not load level $levelId for world $worldId: $e');
      }
    }

    return levels;
  }
}
