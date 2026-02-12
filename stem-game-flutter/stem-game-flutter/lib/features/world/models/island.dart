import 'package:equatable/equatable.dart';

class Island extends Equatable {
  final String id;
  final String code;
  final int worldId;
  final String name;
  final String description;
  final String topicCategory;
  final int orderIndex;
  final String? iconUrl;
  final Map<String, dynamic>? unlockRequirements;
  final bool isActive;
  final bool isUnlocked;
  final IslandProgress? userProgress;

  const Island({
    required this.id,
    required this.code,
    required this.worldId,
    required this.name,
    required this.description,
    required this.topicCategory,
    required this.orderIndex,
    this.iconUrl,
    this.unlockRequirements,
    this.isActive = true,
    this.isUnlocked = true,
    this.userProgress,
  });

  factory Island.fromJson(Map<String, dynamic> json) {
    return Island(
      id: json['id'] as String,
      code: json['code'] as String,
      worldId: json['worldId'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      topicCategory: json['topicCategory'] as String,
      orderIndex: json['orderIndex'] as int,
      iconUrl: json['iconUrl'] as String?,
      unlockRequirements: json['unlockRequirements'] as Map<String, dynamic>?,
      isActive: json['isActive'] as bool? ?? true,
      isUnlocked: json['isUnlocked'] as bool? ?? true,
      userProgress: json['userProgress'] != null
          ? IslandProgress.fromJson(json['userProgress'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'worldId': worldId,
      'name': name,
      'description': description,
      'topicCategory': topicCategory,
      'orderIndex': orderIndex,
      if (iconUrl != null) 'iconUrl': iconUrl,
      if (unlockRequirements != null) 'unlockRequirements': unlockRequirements,
      'isActive': isActive,
      'isUnlocked': isUnlocked,
      if (userProgress != null) 'userProgress': userProgress!.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        code,
        worldId,
        name,
        description,
        topicCategory,
        orderIndex,
        iconUrl,
        unlockRequirements,
        isActive,
        isUnlocked,
        userProgress,
      ];
}

class IslandProgress extends Equatable {
  final String id;
  final String userId;
  final String islandId;
  final String? topicId;
  final int totalXp;
  final int levelsCompleted;
  final int totalLevels;
  final double averageStars;
  final String masteryColor;
  final bool topicBadgeEarned;
  final DateTime? badgeEarnedAt;

  const IslandProgress({
    required this.id,
    required this.userId,
    required this.islandId,
    this.topicId,
    required this.totalXp,
    required this.levelsCompleted,
    required this.totalLevels,
    required this.averageStars,
    required this.masteryColor,
    required this.topicBadgeEarned,
    this.badgeEarnedAt,
  });

  /// Get mastery label based on color
  String get masteryLabel {
    switch (masteryColor) {
      case 'red':
        return 'Started';
      case 'yellow':
        return 'Practicing';
      case 'green':
        return 'Mastered';
      default:
        return 'Not Started';
    }
  }

  /// Get completion percentage
  double get completionPercentage {
    if (totalLevels == 0) return 0.0;
    return (levelsCompleted / totalLevels).clamp(0.0, 1.0);
  }

  factory IslandProgress.fromJson(Map<String, dynamic> json) {
    return IslandProgress(
      id: json['id'] as String,
      userId: json['userId'] as String,
      islandId: json['islandId'] as String,
      topicId: json['topicId'] as String?,
      totalXp: json['totalXp'] as int,
      levelsCompleted: json['levelsCompleted'] as int,
      totalLevels: json['totalLevels'] as int,
      averageStars: (json['averageStars'] as num).toDouble(),
      masteryColor: json['masteryColor'] as String,
      topicBadgeEarned: json['topicBadgeEarned'] as bool,
      badgeEarnedAt: json['badgeEarnedAt'] != null
          ? DateTime.parse(json['badgeEarnedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'islandId': islandId,
      if (topicId != null) 'topicId': topicId,
      'totalXp': totalXp,
      'levelsCompleted': levelsCompleted,
      'totalLevels': totalLevels,
      'averageStars': averageStars,
      'masteryColor': masteryColor,
      'topicBadgeEarned': topicBadgeEarned,
      if (badgeEarnedAt != null) 'badgeEarnedAt': badgeEarnedAt!.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        islandId,
        topicId,
        totalXp,
        levelsCompleted,
        totalLevels,
        averageStars,
        masteryColor,
        topicBadgeEarned,
        badgeEarnedAt,
      ];
}
