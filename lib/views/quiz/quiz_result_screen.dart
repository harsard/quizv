
import 'package:flutter/material.dart';

import '../../constants/app_routes.dart';
import '../../models/quiz_result.dart';
import '../../providers/result_calculator.dart';

class QuizResultScreen extends StatefulWidget {
  final ResultCalculator resultCalculator;

  const QuizResultScreen({Key? key, required this.resultCalculator})
      : super(key: key);

  @override
  _QuizResultScreenState createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  late QuizResult _quizResult;

  @override
  void initState() {
    super.initState();
    _quizResult = widget.resultCalculator.calculateResult();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz Result"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      'You got ${_quizResult.correctAnswers} out of ${_quizResult.totalQuestions} correct!',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, AppRoutes.quizPlay,
                            arguments: widget.resultCalculator.quiz);
                      },
                      child: const Text("Retake Quiz")),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.quizReview,
                            arguments: widget.resultCalculator);
                      },
                      child: const Text("Review Answers")),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRoutes.quizList, (route) => false);
                      },
                      child: const Text("Go back to Quiz List")),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
