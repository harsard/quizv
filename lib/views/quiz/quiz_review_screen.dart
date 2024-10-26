import 'package:flutter/material.dart';

import '../../constants/app_routes.dart';
import '../../models/answer.dart';
import '../../models/question.dart';
import '../../providers/result_calculator.dart';

class QuizReviewScreen extends StatefulWidget {
  final ResultCalculator resultCalculator;

  const QuizReviewScreen({Key? key, required this.resultCalculator})
      : super(key: key);

  @override
  _QuizReviewScreenState createState() => _QuizReviewScreenState();
}

class _QuizReviewScreenState extends State<QuizReviewScreen> {
  bool _showWrongAnswersOnly = false;
  late ResultCalculator _resultCalculator;

  @override
  void initState() {
    super.initState();
    _resultCalculator = widget.resultCalculator;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz Review",style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[100]!, Colors.blue[500]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                itemCount: _resultCalculator.quiz.questions.length,
                itemBuilder: (context, index) {
                  return _buildQuestionCard(
                      _resultCalculator.quiz.questions[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 30),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.quizList, (route) => false);
                    },
                    child: const Text("Back to Quiz List", style: TextStyle(color: Colors.white),),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 30),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      setState(() {
                        _showWrongAnswersOnly = !_showWrongAnswersOnly;
                        _updateResultCalculator();
                      });
                    },
                    child: Text(_showWrongAnswersOnly
                        ? "Show All Answers"
                        : "Show Bad Answers",style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateResultCalculator() {
    if (_showWrongAnswersOnly) {
      var wrongAnswers = <int, List<int>>{};
      for (Question question in _resultCalculator.quiz.questions) {
        List<int> selectedAnswerIDs =
            _resultCalculator.answers[question.id] ?? [];
        bool isCorrect = _isCorrect(question, selectedAnswerIDs);
        if (!isCorrect) {
          wrongAnswers[question.id] = selectedAnswerIDs;
        }
      }
      _resultCalculator = ResultCalculator(
        quiz: _resultCalculator.quiz.copyWith(
          questions: _resultCalculator.quiz.questions
              .where((question) => wrongAnswers.containsKey(question.id))
              .toList(),
        ),
      );
      _resultCalculator.setAnswers(wrongAnswers);
    } else {
      _resultCalculator = widget.resultCalculator;
    }
  }

  bool _isCorrect(Question question, List<int> selectedAnswerIDs) {
    bool isCorrect = true;
    for (Answer answer in question.answers) {
      if ((selectedAnswerIDs.contains(answer.id) && !answer.correct) ||
          (!selectedAnswerIDs.contains(answer.id) && answer.correct)) {
        isCorrect = false;
        break;
      }
    }
    return isCorrect;
  }

  Widget _buildQuestionCard(Question question) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              question.questionText,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: question.answers.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Text(question.answers[index].text),
                    value: _resultCalculator.answers[question.id]
                        ?.contains(question.answers[index].id) ??
                        false,
                    onChanged: null,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: Colors.green,
                    checkColor: Colors.white,
                    secondary: question.answers[index].correct
                        ? const Icon(Icons.check, color: Colors.green)
                        : const Icon(Icons.close, color: Colors.red),
                  );
                },
              ),
            ),
            Text(
              _getAnswerStatus(question),
              style: TextStyle(
                fontSize: 18,
                color: _getAnswerStatusColor(question),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAnswerStatus(Question question) {
    List<int> selectedAnswerIDs = _resultCalculator.answers[question.id] ?? [];
    if (_isCorrect(question, selectedAnswerIDs)) {
      return "Correct";
    } else if (selectedAnswerIDs.isEmpty) {
      return "Not Answered";
    } else {
      return "Incorrect";
    }
  }

  Color _getAnswerStatusColor(Question question) {
    List<int> selectedAnswerIDs = _resultCalculator.answers[question.id] ?? [];
    if (_isCorrect(question, selectedAnswerIDs)) {
      return Colors.green;
    } else if (selectedAnswerIDs.isEmpty) {
      return Colors.grey;
    } else {
      return Colors.red;
    }
  }
}
