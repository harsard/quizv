import 'answer.dart';

class Question {
  final int id;
  final int quizID;
  final String questionText;
  final bool isMultipleChoice;
  final List<Answer> answers;

  Question({
    required this.id,
    required this.quizID,
    required this.questionText,
    required this.isMultipleChoice,
    required this.answers,
  });
}
