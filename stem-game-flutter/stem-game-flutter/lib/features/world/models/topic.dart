import 'package:equatable/equatable.dart';
import 'island.dart';

class Topic extends Equatable {
  final String id;
  final String islandId;
  final String code;
  final String name;
  final String description;
  final List<String> learningObjectives;
  final int orderIndex;
  final String? iconUrl;
  final String difficultyLevel;
  final int levelCount;
  final bool? isUnlocked;
  final IslandProgress? userProgress;

  const Topic({
    required this.id,
    required this.islandId,
    required this.code,
    required this.name,
    required this.description,
    required this.learningObjectives,
    required this.orderIndex,
    this.iconUrl,
    required this.difficultyLevel,
    required this.levelCount,
    this.isUnlocked,
    this.userProgress,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as String? ?? '',
      islandId: json['islandId'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Topic',
      description: json['description'] as String? ?? '',
      learningObjectives: (json['learningObjectives'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      orderIndex: json['orderIndex'] as int? ?? 0,
      iconUrl: json['iconUrl'] as String?,
      difficultyLevel: json['difficultyLevel'] as String? ?? 'beginner',
      levelCount: json['levelCount'] as int? ?? 0,
      isUnlocked: json['isUnlocked'] as bool?,
      userProgress: json['userProgress'] != null
          ? IslandProgress.fromJson(json['userProgress'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'islandId': islandId,
      'code': code,
      'name': name,
      'description': description,
      'learningObjectives': learningObjectives,
      'orderIndex': orderIndex,
      if (iconUrl != null) 'iconUrl': iconUrl,
      'difficultyLevel': difficultyLevel,
      'levelCount': levelCount,
      if (isUnlocked != null) 'isUnlocked': isUnlocked,
      if (userProgress != null) 'userProgress': userProgress!.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        islandId,
        code,
        name,
        description,
        learningObjectives,
        orderIndex,
        iconUrl,
        difficultyLevel,
        levelCount,
        isUnlocked,
        userProgress,
      ];
}
