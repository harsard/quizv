import 'package:quizv/models/quiz.dart';

class QuizResult {
  final Quiz quiz;
  final int correctAnswers;
  final int totalQuestions;

  QuizResult(
      {required this.quiz,
      required this.correctAnswers,
      required this.totalQuestions});
}
