import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../features/world/models/island.dart';
import '../../features/world/models/topic.dart';

class IslandRepository {
  final String baseUrl = ApiConstants.baseUrl;

  /// Get all islands for a specific world
  /// Returns a list of islands with user progress (if authenticated)
  Future<List<Island>> getWorldIslands(int worldId, {String? token}) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('$baseUrl/islands/$worldId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final islandsJson = data['data'] as List<dynamic>;
          return islandsJson
              .map((json) => Island.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch islands');
        }
      } else {
        throw Exception('Failed to fetch islands: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching islands: $e');
    }
  }

  /// Get all topics for a specific island
  /// Returns a list of topics with user progress (if authenticated)
  Future<List<Topic>> getIslandTopics(String islandId, {String? token}) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('$baseUrl/islands/$islandId/topics'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final topicsJson = data['data']['topics'] as List<dynamic>;
          return topicsJson
              .map((json) => Topic.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch topics');
        }
      } else {
        throw Exception('Failed to fetch topics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching topics: $e');
    }
  }

  /// Get all level IDs for a specific topic
  /// Returns a list of level information with completion status
  Future<List<int>> getTopicLevelIds(String topicId, {String? token}) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('$baseUrl/topics/$topicId/levels'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final levelsJson = data['data']['levels'] as List<dynamic>;
          return levelsJson
              .map((json) => json['levelId'] as int)
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch levels');
        }
      } else {
        throw Exception('Failed to fetch levels: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching levels: $e');
    }
  }

  /// Get user's progress across all islands
  Future<List<IslandProgress>> getUserIslandProgress(
    String userId,
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/progress/islands/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final progressJson = data['data'] as List<dynamic>;
          return progressJson
              .map((json) => IslandProgress.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch progress');
        }
      } else {
        throw Exception('Failed to fetch progress: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching progress: $e');
    }
  }
}
