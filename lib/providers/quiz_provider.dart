import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../models/answer.dart';
import '../models/question.dart';
import '../models/quiz.dart';
import 'authentication_provider.dart';

class QuizProvider with ChangeNotifier {
  final authProvider = AuthenticationProvider();

  final List<Quiz> _quizzes = [];

  List<Quiz> get quizzes => _quizzes;

  Future<void> fetchQuizzes() async {
    var authToken = await authProvider.accessToken;
    final response = await http.get(
      Uri.parse('$API_URL/quizzes'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken'
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      log(data.toString());
      for (dynamic quiz in data) {
        int id = quiz['id'];
        Quiz tmpQuiz = Quiz(
          id: id,
          title: quiz['title'],
          description: quiz['description'],
          questions: (quiz['questions'] as List<dynamic>)
              .map((json) => Question(
                    id: json['id'],
                    quizID: id,
                    questionText: json['prompt'],
                    answers: (json['answers'] as List<dynamic>)
                        .map((json) => Answer(
                              id: json['id'],
                              text: json['text'],
                              correct: json['correct'],
                            ))
                        .toList(),
                    isMultipleChoice: true,
                  ))
              .toList(),
        );
        _quizzes.add(tmpQuiz);
      }
      notifyListeners();
    } else {
      log('Failed to fetch quizzes: ${response.statusCode}');
      throw Exception('Failed to fetch quizzes');
    }
  }

  Future<Quiz> updateQuiz(int quizID, String title, String description) async {
    var authToken = await authProvider.accessToken;
    final response = await http.put(Uri.parse('$API_URL/quizzes/$quizID'),
        body: jsonEncode(<String, String>{
          'title': title,
          'description': description,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken'
        });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      notifyListeners();
      return Quiz(
        id: data['id'],
        title: data['title'],
        description: data['description'],
        questions: (data['questions'] as List<dynamic>)
            .map((json) => Question(
                  id: json['id'],
                  quizID: data['id'],
                  questionText: json['prompt'],
                  answers: (json['answers'] as List<dynamic>)
                      .map((json) => Answer(
                            id: json['id'],
                            text: json['text'],
                            correct: json['correct'],
                          ))
                      .toList(),
                  isMultipleChoice: true,
                ))
            .toList(),
      );
    } else {
      log('Failed to update quiz: ${response.statusCode}');
      throw Exception('Failed to update quiz');
    }
  }

  Future<Quiz> addQuestion(
      int quizID, String prompt, List<Answer> answers) async {
    var authToken = await authProvider.accessToken;
    final response = await http.post(
        Uri.parse('$API_URL/quizzes/$quizID/question'),
        body: jsonEncode(<String, Object>{
          'prompt': prompt,
          'answers': answers.map((answer) => answer.toJson()).toList(),
        }),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken'
        });
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      notifyListeners();
      return Quiz(
        id: data['id'],
        title: data['title'],
        description: data['description'],
        questions: (data['questions'] as List<dynamic>)
            .map((json) => Question(
                  id: json['id'],
                  quizID: data['id'],
                  questionText: json['prompt'],
                  answers: (json['answers'] as List<dynamic>)
                      .map((json) => Answer(
                            id: json['id'],
                            text: json['text'],
                            correct: json['correct'],
                          ))
                      .toList(),
                  isMultipleChoice: true,
                ))
            .toList(),
      );
    } else {
      log('Failed to add question: ${response.statusCode}');
      throw Exception('Failed to add question');
    }
  }

  Future<Quiz> addQuiz(String title, String description) async {
    var authToken = await authProvider.accessToken;
    final response = await http.post(Uri.parse('$API_URL/quizzes'),
        body: jsonEncode(<String, String>{
          'title': title,
          'description': description,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken'
        });

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      notifyListeners();
      return Quiz(
        id: data['id'],
        title: data['title'],
        description: data['description'],
        questions: (data['questions'] as List<dynamic>)
            .map((json) => Question(
                  id: json['id'],
                  quizID: data['id'],
                  questionText: json['prompt'],
                  answers: (json['answers'] as List<dynamic>)
                      .map((json) => Answer(
                            id: json['id'],
                            text: json['text'],
                            correct: json['correct'],
                          ))
                      .toList(),
                  isMultipleChoice: true,
                ))
            .toList(),
      );
    } else {
      log('Failed to add quiz: ${response.statusCode}');
      throw Exception('Failed to add quiz');
    }
  }

  Future<Quiz> updateQuestion(
      int quizID, int id, String prompt, List<Answer> answers) async {
    var authToken = await authProvider.accessToken;
    final response = await http.put(
        Uri.parse('$API_URL/quizzes/$quizID/question/$id'),
        body: jsonEncode(
          <String, Object>{
            'prompt': prompt,
            'answers': answers.map((answer) => answer.toJson()).toList(),
          },
        ),
        headers: <String, String>{
          "Content-Type": "application/json",
          "Authorization": "Bearer $authToken"
        });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      notifyListeners();
      return Quiz(
        id: data['id'],
        title: data['title'],
        description: data['description'],
        questions: (data['questions'] as List<dynamic>)
            .map((json) => Question(
                  id: json['id'],
                  quizID: data['id'],
                  questionText: json['prompt'],
                  answers: (json['answers'] as List<dynamic>)
                      .map((json) => Answer(
                            id: json['id'],
                            text: json['text'],
                            correct: json['correct'],
                          ))
                      .toList(),
                  isMultipleChoice: true,
                ))
            .toList(),
      );
    } else {
      log('Failed to update question: ${response.statusCode}');
      throw Exception('Failed to update question');
    }
  }

  Future<void> deleteQuiz(int id) async {
    var authToken = await authProvider.accessToken;
    final response = await http.delete(Uri.parse('$API_URL/quizzes/$id'),
        headers: <String, String>{
          'Content-Type': 'application-json',
          'Authorization': 'Bearer $authToken'
        });
    if (response.statusCode == 200) {
      notifyListeners();
    } else {
      log('Failed to delete quiz: ${response.statusCode}');
      throw Exception('Failed to delete quiz');
    }
  }

  Future<void> deleteQuestion(int quizID, int id) async {
    var authToken = await authProvider.accessToken;
    final response = await http.delete(
        Uri.parse('$API_URL/quizzes/$quizID/question/$id'),
        headers: <String, String>{
          'Content-Type': 'application-json',
          'Authorization': 'Bearer $authToken'
        });

    if (response.statusCode == 200) {
      notifyListeners();
    } else {
      log('Failed to delete question: ${response.statusCode}');
      throw Exception('Failed to delete question');
    }
  }
}
