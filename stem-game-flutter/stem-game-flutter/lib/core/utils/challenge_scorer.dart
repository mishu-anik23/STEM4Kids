import 'dart:math';
import '../../features/game/models/challenge_data.dart';

class ChallengeScorer {
  static int calculateScore(
      ChallengeType type, Map<String, dynamic> results) {
    switch (type) {
      case ChallengeType.tapObjects:
        return _scoreTapObjects(results);
      case ChallengeType.sortItems:
        return _scoreSortItems(results);
      case ChallengeType.pathFinding:
        return _scorePathFinding(results);
      case ChallengeType.puzzle:
        return _scorePuzzle(results);
      case ChallengeType.memoryGame:
        return _scoreMemoryGame(results);
      case ChallengeType.matching:
        return _scoreMatching(results);
      case ChallengeType.sequencing:
        return _scoreSequencing(results);
      case ChallengeType.multipleChoice:
        return _scoreMultipleChoice(results);
      case ChallengeType.dragDrop:
        return _scoreDragDrop(results);
      case ChallengeType.interactiveScene:
        return _scoreInteractiveScene(results);
    }
  }

  static int _scoreTapObjects(Map<String, dynamic> results) {
    final correctTaps = results['correctTaps'] as int? ?? 0;
    final wrongTaps = results['wrongTaps'] as int? ?? 0;
    final totalTargets = results['totalTargets'] as int? ?? 1;
    final accuracy = totalTargets > 0 ? correctTaps / totalTargets : 0.0;
    final penalty = wrongTaps * 5;
    return max(0, min(100, (accuracy * 100).round() - penalty));
  }

  static int _scoreSortItems(Map<String, dynamic> results) {
    final correctPlacements = results['correctPlacements'] as int? ?? 0;
    final totalItems = results['totalItems'] as int? ?? 1;
    return totalItems > 0
        ? min(100, ((correctPlacements / totalItems) * 100).round())
        : 0;
  }

  static int _scorePathFinding(Map<String, dynamic> results) {
    final reachedEnd = results['reachedEnd'] as bool? ?? false;
    final wrongSteps = results['wrongSteps'] as int? ?? 0;
    if (!reachedEnd) return 0;
    return max(50, 100 - (wrongSteps * 10));
  }

  static int _scorePuzzle(Map<String, dynamic> results) {
    final coverageAchieved = (results['coverageAchieved'] as num?)?.toDouble() ?? 0.0;
    final targetCoverage = (results['targetCoverage'] as num?)?.toDouble() ?? 1.0;
    return min(100, ((coverageAchieved / targetCoverage) * 100).round());
  }

  static int _scoreMemoryGame(Map<String, dynamic> results) {
    final pairsMatched = results['pairsMatched'] as int? ?? 0;
    final totalPairs = results['totalPairs'] as int? ?? 1;
    final moves = results['moves'] as int? ?? 0;
    final optimalMoves = totalPairs * 2;
    final baseScore =
        totalPairs > 0 ? (pairsMatched / totalPairs * 70).round() : 0;
    final efficiencyBonus = moves <= (optimalMoves * 1.5).round()
        ? 30
        : max(0, 30 - (moves - optimalMoves));
    return min(100, baseScore + efficiencyBonus);
  }

  static int _scoreMatching(Map<String, dynamic> results) {
    final correctChoices = results['correctChoices'] as int? ?? 0;
    final totalScenarios = results['totalScenarios'] as int? ?? 1;
    return totalScenarios > 0
        ? min(100, ((correctChoices / totalScenarios) * 100).round())
        : 0;
  }

  static int _scoreSequencing(Map<String, dynamic> results) {
    final correctSequences = results['correctSequences'] as int? ?? 0;
    final totalSequences = results['totalSequences'] as int? ?? 1;
    return totalSequences > 0
        ? min(100, ((correctSequences / totalSequences) * 100).round())
        : 0;
  }

  static int _scoreMultipleChoice(Map<String, dynamic> results) {
    final correctAnswers = results['correctAnswers'] as int? ?? 0;
    final totalQuestions = results['totalQuestions'] as int? ?? 1;
    return totalQuestions > 0
        ? min(100, ((correctAnswers / totalQuestions) * 100).round())
        : 0;
  }

  static int _scoreDragDrop(Map<String, dynamic> results) {
    final correctPlacements = results['correctPlacements'] as int? ?? 0;
    final totalItems = results['totalItems'] as int? ?? 1;
    return totalItems > 0
        ? min(100, ((correctPlacements / totalItems) * 100).round())
        : 0;
  }

  static int _scoreInteractiveScene(Map<String, dynamic> results) {
    final objectivesCompleted =
        results['objectivesCompleted'] as int? ?? 0;
    final totalObjectives = results['totalObjectives'] as int? ?? 1;
    return totalObjectives > 0
        ? min(100, ((objectivesCompleted / totalObjectives) * 100).round())
        : 0;
  }

  static int calculateStars(int score) {
    if (score >= 90) return 3;
    if (score >= 70) return 2;
    if (score >= 50) return 1;
    return 0;
  }
}
