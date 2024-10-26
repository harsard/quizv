
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizv/providers/connectivity_provider.dart';
import 'dart:developer' as developer;
import '../../constants/app_routes.dart';
import '../../models/quiz_result.dart';
import '../../providers/quiz_provider.dart';
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
  late Stream<ConnectivityResult> _connectivityStream;

  @override
  void initState() {
    super.initState();
    _quizResult = widget.resultCalculator.calculateResult();
    // Initialize the connectivity stream
    _connectivityStream = Connectivity().onConnectivityChanged;
    developer.log('listning');
    _saveScore();


    // _connectivityStream.listen((ConnectivityResult result) {
    //   if (result == ConnectivityResult.wifi) {
    //     developer.log('sync_connectivityStream:==$ConnectivityResult');
    //     _syncScore();
    //   } else if (result == ConnectivityResult.none) {
    //     developer.log('No internet');
    //     developer.log('connectivityStream:==$ConnectivityResult');
    //     // _saveScore();
    //   }
    // });
  }

  Future<void> _saveScore() async {
    QuizProvider quizProvider= QuizProvider();
    double percentage = (_quizResult.correctAnswers / _quizResult.totalQuestions) * 100;
    await quizProvider.saveScore(percentage);
  }


  @override
  Widget build(BuildContext context) {
    double percentage = (_quizResult.correctAnswers / _quizResult.totalQuestions) * 100;
    String score= 'You got ${_quizResult.correctAnswers} out of ${_quizResult.totalQuestions} correct!';
    final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;
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
                      'You score: ${percentage.toStringAsFixed(2)}%',
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
