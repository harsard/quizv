import 'package:flutter/material.dart';
import '../../constants/app_routes.dart';
import '../../models/question.dart';
import '../../models/quiz.dart';
import '../../providers/result_calculator.dart';

class QuizPlayScreen extends StatefulWidget {
  final Quiz quiz;

  const QuizPlayScreen({super.key, required this.quiz});

  @override
  _QuizPlayScreenState createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  late ResultCalculator _resultCalculator;
  int index = 1;

  @override
  void initState() {
    _resultCalculator = ResultCalculator(quiz: widget.quiz);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              onPageChanged: (value) => setState(() => index = value + 1),
              itemCount: widget.quiz.questions.length,
              itemBuilder: (context, index) {
                return _buildQuestionCard(widget.quiz.questions[index]);
              },
            ),
          ),
          Text("Question $index of ${widget.quiz.questions.length}",
              style: const TextStyle(fontSize: 16)),
          ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.quizResult,
                    arguments: _resultCalculator);
              },
              child: const Text("Submit Quiz"))
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Question question) {
    return Card(
        borderOnForeground: true,
        elevation: 5,
        margin: const EdgeInsets.all(10),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(question.questionText,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              Expanded(
                child: ListView.builder(
                  itemCount: question.answers.length,
                  itemBuilder: (context, index) {
                    return CheckboxListTile(
                      title: Text(question.answers[index].text),
                      value: _resultCalculator.answers[question.id]
                              ?.contains(question.answers[index].id) ??
                          false,
                      onChanged: (value) {
                        setState(() {
                          var answers = _resultCalculator.answers;
                          var quiz = _resultCalculator.quiz;

                          if (value == true) {
                            if (question.answers[index].id != null) {
                              answers[question.id] = [
                                ...answers[question.id] ?? [],
                                question.answers[index].id!
                              ];
                              _resultCalculator = ResultCalculator(quiz: quiz);
                              _resultCalculator.setAnswers(answers);
                            }
                          } else {
                            if (question.answers[index].id != null) {
                              answers[question.id] = [
                                ...answers[question.id] ?? []
                              ];
                              answers[question.id]
                                  ?.remove(question.answers[index].id);
                              _resultCalculator = ResultCalculator(quiz: quiz);
                              _resultCalculator.setAnswers(answers);
                            }
                          }
                        });
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ));
  }
}
