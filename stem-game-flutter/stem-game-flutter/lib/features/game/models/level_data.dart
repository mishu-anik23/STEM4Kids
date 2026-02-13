import 'package:equatable/equatable.dart';
import 'challenge_data.dart';

enum QuestionType {
  multipleChoice,
  fillInBlank,
  dragAndDrop,
  wordProblem,
}

class LevelData extends Equatable {
  final int levelId;
  final int worldId;
  final String title;
  final String description;
  final String difficulty;
  final String theme;
  final String mathType;
  final List<int> targetGrade;
  final int totalQuestions;
  final int passingScore;
  final List<Question> questions;
  final ChallengeData? challenge;

  const LevelData({
    required this.levelId,
    required this.worldId,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.theme,
    required this.mathType,
    required this.targetGrade,
    required this.totalQuestions,
    required this.passingScore,
    required this.questions,
    this.challenge,
  });

  bool get isChallengeMode => challenge != null;

  factory LevelData.fromJson(Map<String, dynamic> json) {
    ChallengeData? challenge;
    if (json['challengeType'] != null && json['challengeConfig'] != null) {
      challenge = ChallengeData.fromJson(json);
    }

    return LevelData(
      levelId: json['levelId'] as int,
      worldId: json['worldId'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      difficulty: json['difficulty'] as String,
      theme: json['theme'] as String,
      mathType: json['mathType'] as String,
      targetGrade: (json['targetGrade'] as List<dynamic>).cast<int>(),
      totalQuestions: json['totalQuestions'] as int,
      passingScore: json['passingScore'] as int,
      questions: (json['questions'] as List<dynamic>)
          .map((q) => Question.fromJson(q as Map<String, dynamic>))
          .toList(),
      challenge: challenge,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'levelId': levelId,
      'worldId': worldId,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'theme': theme,
      'mathType': mathType,
      'targetGrade': targetGrade,
      'totalQuestions': totalQuestions,
      'passingScore': passingScore,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        levelId,
        worldId,
        title,
        description,
        difficulty,
        theme,
        mathType,
        targetGrade,
        totalQuestions,
        passingScore,
        questions,
        challenge,
      ];
}

class Question extends Equatable {
  final String id;
  final QuestionType type;
  final String questionText;
  final String correctAnswer;
  final List<String>? options;
  final String explanation;
  final List<Hint> hints;

  const Question({
    required this.id,
    required this.type,
    required this.questionText,
    required this.correctAnswer,
    this.options,
    required this.explanation,
    required this.hints,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    QuestionType parseType(String typeString) {
      switch (typeString) {
        case 'multiple_choice':
          return QuestionType.multipleChoice;
        case 'fill_in_blank':
          return QuestionType.fillInBlank;
        case 'drag_and_drop':
          return QuestionType.dragAndDrop;
        case 'word_problem':
          return QuestionType.wordProblem;
        default:
          return QuestionType.multipleChoice;
      }
    }

    return Question(
      id: json['id'] as String,
      type: parseType(json['type'] as String),
      questionText: json['questionText'] as String,
      correctAnswer: json['correctAnswer'] as String,
      options: json['options'] != null
          ? (json['options'] as List<dynamic>).cast<String>()
          : null,
      explanation: json['explanation'] as String,
      hints: (json['hints'] as List<dynamic>)
          .map((h) => Hint.fromJson(h as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    String typeToString(QuestionType type) {
      switch (type) {
        case QuestionType.multipleChoice:
          return 'multiple_choice';
        case QuestionType.fillInBlank:
          return 'fill_in_blank';
        case QuestionType.dragAndDrop:
          return 'drag_and_drop';
        case QuestionType.wordProblem:
          return 'word_problem';
      }
    }

    return {
      'id': id,
      'type': typeToString(type),
      'questionText': questionText,
      'correctAnswer': correctAnswer,
      if (options != null) 'options': options,
      'explanation': explanation,
      'hints': hints.map((h) => h.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        type,
        questionText,
        correctAnswer,
        options,
        explanation,
        hints,
      ];
}

class Hint extends Equatable {
  final int level;
  final String text;
  final bool showsAnswer;

  const Hint({
    required this.level,
    required this.text,
    this.showsAnswer = false,
  });

  factory Hint.fromJson(Map<String, dynamic> json) {
    return Hint(
      level: json['level'] as int,
      text: json['text'] as String,
      showsAnswer: json['showsAnswer'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'text': text,
      'showsAnswer': showsAnswer,
    };
  }

  @override
  List<Object?> get props => [level, text, showsAnswer];
}
