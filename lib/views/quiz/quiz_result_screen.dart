
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
  }

  Future<void> _saveScore() async {
    QuizProvider quizProvider= QuizProvider();
    double percentage = (_quizResult.correctAnswers / _quizResult.totalQuestions) * 100;
    await quizProvider.saveScore(percentage);
  }


  @override
  Widget build(BuildContext context) {
    double percentage = (_quizResult.correctAnswers / _quizResult.totalQuestions) * 100;
    String scoreMessage = 'You got score is : $percentage %';
    final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz Result"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[200]!, Colors.blue[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Your Score',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${percentage.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.quizPlay,
                          arguments: widget.resultCalculator.quiz,
                        );
                      },
                      child: const Text("Retake Quiz",style: TextStyle(color: Colors.white),),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.quizReview,
                          arguments: widget.resultCalculator
                        );
                      },
                      child: const Text("Review Answers",style: TextStyle(color: Colors.white),),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.quizList,
                              (route) => false,
                        );
                      },
                      child: const Text("Go back to Quiz List",style: TextStyle(color: Colors.white),),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
