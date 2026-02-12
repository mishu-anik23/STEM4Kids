class AnswerValidator {
  static bool validateAnswer(String userAnswer, String correctAnswer) {
    final cleanedUserAnswer = userAnswer.trim().toLowerCase();
    final cleanedCorrectAnswer = correctAnswer.trim().toLowerCase();

    return cleanedUserAnswer == cleanedCorrectAnswer;
  }

  static bool isValidNumericInput(String input) {
    if (input.isEmpty) return false;

    final number = int.tryParse(input.trim());
    return number != null;
  }

  static bool isInReasonableRange(String input, {int min = -1000, int max = 1000}) {
    final number = int.tryParse(input.trim());
    if (number == null) return false;

    return number >= min && number <= max;
  }
}
