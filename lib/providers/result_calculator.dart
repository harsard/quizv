

import '../models/answer.dart';
import '../models/question.dart';
import '../models/quiz.dart';
import '../models/quiz_result.dart';

class ResultCalculator {
  final Quiz quiz;

  final Map<int, List<int>> answers;

  ResultCalculator({required this.quiz}) : answers = {};

  void addAnswers(int questionID, List<int> answerIDs) {
    answers[questionID] = answerIDs;
  }

  void setAnswers(Map<int, List<int>> answers) {
    this.answers.clear();
    this.answers.addAll(answers);
  }

  QuizResult calculateResult() {
    int correctAnswers = 0;
    for (Question question in quiz.questions) {
      List<int> selectedAnswerIDs = answers[question.id] ?? [];
      bool isCorrect = true;
      for (Answer answer in question.answers) {
        if ((selectedAnswerIDs.contains(answer.id) && !answer.correct) ||
            (!selectedAnswerIDs.contains(answer.id) && answer.correct)) {
          isCorrect = false;
          break;
        }
      }
      if (isCorrect) {
        correctAnswers++;
      }
    }
    return QuizResult(
        quiz: quiz,
        correctAnswers: correctAnswers,
        totalQuestions: quiz.questions.length);
  }
}
