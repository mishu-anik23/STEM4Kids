import 'package:equatable/equatable.dart';

enum ChallengeType {
  tapObjects,
  sortItems,
  pathFinding,
  puzzle,
  memoryGame,
  matching,
  sequencing,
  multipleChoice,
  dragDrop,
  interactiveScene;

  static ChallengeType fromString(String value) {
    switch (value) {
      case 'tap_objects':
        return ChallengeType.tapObjects;
      case 'sort_items':
        return ChallengeType.sortItems;
      case 'path_finding':
        return ChallengeType.pathFinding;
      case 'puzzle':
        return ChallengeType.puzzle;
      case 'memory_game':
        return ChallengeType.memoryGame;
      case 'matching':
        return ChallengeType.matching;
      case 'sequencing':
        return ChallengeType.sequencing;
      case 'multiple_choice':
        return ChallengeType.multipleChoice;
      case 'drag_drop':
        return ChallengeType.dragDrop;
      case 'interactive_scene':
        return ChallengeType.interactiveScene;
      default:
        return ChallengeType.multipleChoice;
    }
  }
}

class ChallengeData extends Equatable {
  final ChallengeType challengeType;
  final Map<String, dynamic> challengeConfig;
  final String? storyText;
  final String? lessonContent;
  final List<String> hints;
  final String? successMessage;
  final int maxStars;
  final int xpReward;
  final int coinsReward;
  final int estimatedDurationMinutes;

  const ChallengeData({
    required this.challengeType,
    required this.challengeConfig,
    this.storyText,
    this.lessonContent,
    this.hints = const [],
    this.successMessage,
    this.maxStars = 3,
    this.xpReward = 10,
    this.coinsReward = 5,
    this.estimatedDurationMinutes = 3,
  });

  factory ChallengeData.fromJson(Map<String, dynamic> json) {
    return ChallengeData(
      challengeType: ChallengeType.fromString(json['challengeType'] as String),
      challengeConfig: json['challengeConfig'] as Map<String, dynamic>,
      storyText: json['storyText'] as String?,
      lessonContent: json['lessonContent'] as String?,
      hints: (json['hints'] as List<dynamic>?)
              ?.map((h) => h is String ? h : h.toString())
              .toList() ??
          [],
      successMessage: json['successMessage'] as String?,
      maxStars: json['maxStars'] as int? ?? 3,
      xpReward: json['xpReward'] as int? ?? 10,
      coinsReward: json['coinsReward'] as int? ?? 5,
      estimatedDurationMinutes:
          json['estimatedDurationMinutes'] as int? ?? 3,
    );
  }

  @override
  List<Object?> get props => [
        challengeType,
        challengeConfig,
        storyText,
        lessonContent,
        hints,
        successMessage,
        maxStars,
        xpReward,
        coinsReward,
        estimatedDurationMinutes,
      ];
}
