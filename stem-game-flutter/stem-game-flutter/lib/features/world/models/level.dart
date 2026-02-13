import 'package:equatable/equatable.dart';

class Level extends Equatable {
  final String id;
  final String topicId;
  final int levelNumber;
  final String code;
  final String name;
  final String description;
  final String challengeType;
  final Map<String, dynamic>? challengeConfig;
  final String? storyText;
  final String? lessonContent;
  final List<String> hints;
  final String? successMessage;
  final String difficultyLevel;
  final int? estimatedDurationMinutes;
  final int maxStars;
  final int xpReward;
  final int coinsReward;
  final bool? isUnlocked;
  final LevelProgress? userProgress;

  const Level({
    required this.id,
    required this.topicId,
    required this.levelNumber,
    required this.code,
    required this.name,
    required this.description,
    required this.challengeType,
    this.challengeConfig,
    this.storyText,
    this.lessonContent,
    required this.hints,
    this.successMessage,
    required this.difficultyLevel,
    this.estimatedDurationMinutes,
    required this.maxStars,
    required this.xpReward,
    required this.coinsReward,
    this.isUnlocked,
    this.userProgress,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'] as String? ?? '',
      topicId: json['topicId'] as String? ?? '',
      levelNumber: json['levelNumber'] as int? ?? 0,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Level',
      description: json['description'] as String? ?? '',
      challengeType: json['challengeType'] as String? ?? 'tap_objects',
      challengeConfig: json['challengeConfig'] as Map<String, dynamic>?,
      storyText: json['storyText'] as String?,
      lessonContent: json['lessonContent'] as String?,
      hints: (json['hints'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      successMessage: json['successMessage'] as String?,
      difficultyLevel: json['difficultyLevel'] as String? ?? 'beginner',
      estimatedDurationMinutes: json['estimatedDurationMinutes'] as int?,
      maxStars: json['maxStars'] as int? ?? 3,
      xpReward: json['xpReward'] as int? ?? 0,
      coinsReward: json['coinsReward'] as int? ?? 0,
      isUnlocked: json['isUnlocked'] as bool?,
      userProgress: json['userProgress'] != null
          ? LevelProgress.fromJson(json['userProgress'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topicId': topicId,
      'levelNumber': levelNumber,
      'code': code,
      'name': name,
      'description': description,
      'challengeType': challengeType,
      if (challengeConfig != null) 'challengeConfig': challengeConfig,
      if (storyText != null) 'storyText': storyText,
      if (lessonContent != null) 'lessonContent': lessonContent,
      'hints': hints,
      if (successMessage != null) 'successMessage': successMessage,
      'difficultyLevel': difficultyLevel,
      if (estimatedDurationMinutes != null)
        'estimatedDurationMinutes': estimatedDurationMinutes,
      'maxStars': maxStars,
      'xpReward': xpReward,
      'coinsReward': coinsReward,
      if (isUnlocked != null) 'isUnlocked': isUnlocked,
      if (userProgress != null) 'userProgress': userProgress!.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        topicId,
        levelNumber,
        code,
        name,
        description,
        challengeType,
        challengeConfig,
        storyText,
        lessonContent,
        hints,
        successMessage,
        difficultyLevel,
        estimatedDurationMinutes,
        maxStars,
        xpReward,
        coinsReward,
        isUnlocked,
        userProgress,
      ];
}

class LevelProgress extends Equatable {
  final bool completed;
  final int? stars;
  final int? timeSpentSeconds;
  final int? attempts;

  const LevelProgress({
    required this.completed,
    this.stars,
    this.timeSpentSeconds,
    this.attempts,
  });

  factory LevelProgress.fromJson(Map<String, dynamic> json) {
    return LevelProgress(
      completed: json['completed'] as bool? ?? false,
      stars: json['stars'] as int?,
      timeSpentSeconds: json['timeSpentSeconds'] as int?,
      attempts: json['attempts'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completed': completed,
      if (stars != null) 'stars': stars,
      if (timeSpentSeconds != null) 'timeSpentSeconds': timeSpentSeconds,
      if (attempts != null) 'attempts': attempts,
    };
  }

  @override
  List<Object?> get props => [completed, stars, timeSpentSeconds, attempts];
}
