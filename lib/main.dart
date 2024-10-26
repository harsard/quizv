import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizv/providers/connectivity_provider.dart';
import 'package:quizv/providers/quiz_provider.dart';
import 'package:quizv/providers/result_calculator.dart';
import 'package:quizv/views/auth/login_screen.dart';
import 'package:quizv/views/auth/register_screen.dart';
import 'package:quizv/views/question/question_detail_screen.dart';
import 'package:quizv/views/question/question_form_screen.dart';
import 'package:quizv/views/quiz/quiz_detail_screen.dart';
import 'package:quizv/views/quiz/quiz_list_screen.dart';
import 'package:quizv/views/quiz/quiz_play_screen.dart';
import 'package:quizv/views/quiz/quiz_result_screen.dart';
import 'package:quizv/views/quiz/quiz_review_screen.dart';

import 'constants/app_routes.dart';
import 'models/question.dart';
import 'models/quiz.dart';

void main() {
  runApp(const MyApp());
  monitorConnectivity();
}

void monitorConnectivity() {
  print('monitorConnectivity=====');
  Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
    if(result != ConnectivityResult.none){
      QuizProvider().syncScores();
    }else{
      print('Internet Connected');
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ConnectivityProvider(),
      child: MaterialApp(
        title: 'Go Quiz',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: AppRoutes.login,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case AppRoutes.login:
              return MaterialPageRoute(builder: (context) => LoginScreen());
            case AppRoutes.register:
              return MaterialPageRoute(builder: (context) => RegisterScreen());
            case AppRoutes.quizList:
              return MaterialPageRoute(
                  builder: (context) => const QuizListScreen());
            case AppRoutes.quizDetail:
              return MaterialPageRoute(
                  builder: (context) =>
                      QuizDetailScreen(quiz: settings.arguments as Quiz));
            case AppRoutes.questionForm:
              return MaterialPageRoute(builder: (context) {
                final args = settings.arguments as QuestionFormScreenArgs;
                return QuestionFormScreen(
                    quizID: args.quizID, question: args.question);
              });
            case AppRoutes.questionDetail:
              return MaterialPageRoute(
                  builder: (context) => QuestionDetailScreen(
                      question: settings.arguments as Question));
            case AppRoutes.quizPlay:
              return MaterialPageRoute(
                  builder: (context) =>
                      QuizPlayScreen(quiz: settings.arguments as Quiz));
            case AppRoutes.quizResult:
              return MaterialPageRoute(
                  builder: (context) => QuizResultScreen(
                      resultCalculator: settings.arguments as ResultCalculator));
            case AppRoutes.quizReview:
              return MaterialPageRoute(
                  builder: (context) => QuizReviewScreen(
                      resultCalculator: settings.arguments as ResultCalculator));
            default:
              return MaterialPageRoute(builder: (context) => LoginScreen());
          }
        },
      ),
    );
  }

}
