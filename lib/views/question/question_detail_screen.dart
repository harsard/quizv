import 'package:flutter/material.dart';
import 'package:quizv/views/question/question_form_screen.dart';


import '../../constants/app_routes.dart';
import '../../models/answer.dart';
import '../../models/question.dart';
import '../../models/quiz.dart';

class QuestionDetailScreen extends StatefulWidget {
  final Question question;

  const QuestionDetailScreen({Key? key, required this.question})
      : super(key: key);

  @override
  _QuestionDetailScreenState createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  late Question question;

  @override
  void initState() {
    super.initState();
    question = widget.question;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, question);
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                icon: const Icon(Icons.edit),
                tooltip: "Edit Question",
                onPressed: () async {
                  Quiz tmpQuiz = await Navigator.pushNamed(
                      context, AppRoutes.questionForm,
                      arguments: QuestionFormScreenArgs(
                          quizID: question.quizID, question: question)) as Quiz;
                  setState(() {
                    question = tmpQuiz.questions
                        .firstWhere((q) => q.id == question.id);
                  });
                })
          ],
          title: const Text('Question Detail'),
        ),
        body: _buildQuestionDetail(),
      ),
    );
  }

  Widget _buildQuestionDetail() {
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(question.questionText,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold))),
          ],
        ),
        const SizedBox(height: 16.0),
        const Text('Answers'),
        const SizedBox(height: 16.0),
        Expanded(
          child: _answerListBuilder(),
        ),
      ],
    );
  }

  Widget _answerListBuilder() {
    final List<Answer> answers = question.answers;

    if (answers.isEmpty) {
      return const Center(
        child: Text('No answers available.'),
      );
    }

    return ListView.builder(
      itemCount: answers.length,
      itemBuilder: (context, index) {
        final answer = answers[index];
        return _buildAnswerTile(context, answer);
      },
    );
  }

  Widget _buildAnswerTile(BuildContext context, Answer answer) {
    return Card(
      child: ListTile(
        title: Text(answer.text),
        trailing: answer.correct
            ? const Icon(Icons.check, color: Colors.green)
            : const Icon(Icons.close, color: Colors.red),
      ),
    );
  }
}
