import 'dart:math';

class ScoreCalculator {
  static const int pointsPerQuestion = 10;
  static const int totalQuestions = 10;
  static const int maxScore = 100;
  static const int hintPenaltyCoins = 2;
  static const int coinsPerStar = 10;

  static int calculateScore(int correctAnswers) {
    return min(correctAnswers * pointsPerQuestion, maxScore);
  }

  static int calculateStars(int score) {
    if (score >= 90) return 3;
    if (score >= 70) return 2;
    if (score >= 50) return 1;
    return 0;
  }

  static int calculateCoins(int stars, int hintsUsed) {
    final baseCoins = stars * coinsPerStar;
    final hintPenalty = hintsUsed * hintPenaltyCoins;
    return max(0, baseCoins - hintPenalty);
  }

  static bool isPassing(int score) {
    return score >= 50;
  }

  static String getStarMessage(int stars) {
    switch (stars) {
      case 3:
        return 'Amazing! Perfect performance!';
      case 2:
        return 'Great job! Keep it up!';
      case 1:
        return 'Good try! Practice makes perfect!';
      default:
        return 'Keep trying! You can do it!';
    }
  }
}
