
import 'package:flutter/material.dart';
import '../../models/answer.dart';
import '../../models/question.dart';
import '../../models/quiz.dart';
import '../../providers/quiz_provider.dart';

class QuestionFormScreenArgs {
  final int quizID;
  final Question? question;

  QuestionFormScreenArgs({required this.quizID, this.question});
}

class QuestionFormScreen extends StatefulWidget {
  final int quizID;
  final Question? question; // if editing a question we need to pass it in

  const QuestionFormScreen({Key? key, required this.quizID, this.question})
      : super(key: key);

  @override
  _QuestionFormScreenState createState() => _QuestionFormScreenState();
}

class _QuestionFormScreenState extends State<QuestionFormScreen> {
  int answerCount = 1;
  String prompt = '';
  List<Answer> answers = [];

  @override
  void initState() {
    answerCount =
        widget.question != null ? widget.question!.answers.length + 1 : 1;
    prompt = widget.question?.questionText ?? '';
    answers = widget.question?.answers ?? [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController promptController =
        TextEditingController(text: prompt);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Question Form'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: promptController,
                onChanged: (value) => prompt = value,
                decoration: const InputDecoration(
                  labelText: 'Question Text',
                  hintText: 'Enter the question prompt',
                ),
              ),
              const SizedBox(height: 16.0),
              const Text('Answers'),
              const SizedBox(height: 16.0),
              Expanded(
                child: _answerListBuilder(),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  Quiz? tmpQuiz = await _addQuestion(prompt, answers);
                  if (tmpQuiz != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Question Saved')));
                    Navigator.pop(context, tmpQuiz);
                  }
                },
                child: const Text('Save Question'),
              )
            ],
          ),
        ));
  }

  // We have a list of answers, at the beginning it's empty and there is a disabled text field that when clicked will add a new answer to the list
  Widget _answerListBuilder() {
    return ListView.builder(
      itemCount: answerCount,
      itemBuilder: (context, index) {
        // if last item, show the add answer button
        if (index == answerCount - 1) {
          return Card(
            child: ListTile(
              title: const Text('Add Answer'),
              onTap: () {
                setState(() {
                  answerCount++;
                });
              },
            ),
          );
        }
        return _answerTileBuilder(index);
      },
    );
  }

  Widget _answerTileBuilder(int index) {
    if (answerCount - 1 > answers.length) {
      answers.add(Answer(correct: false, text: ''));
    }
    final TextEditingController answerController =
        TextEditingController(text: answers[index].text);
    return Card(
        child: ListTile(
            title: TextFormField(
              controller: answerController,
              onChanged: (value) => answers[index] =
                  Answer(correct: answers[index].correct, text: value),
              decoration: const InputDecoration(
                labelText: 'Answer Text',
                hintText: 'Enter the answer text',
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: answers[index].correct,
                  onChanged: (value) => {
                    setState(() {
                      answers[index] =
                          Answer(correct: value, text: answers[index].text);
                    })
                  },
                ),
                IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        answerCount--;
                        answers.removeAt(index);
                      });
                    })
              ],
            )));
  }

  Future<Quiz>? _addQuestion(String prompt, List<Answer> answers) {
    QuizProvider quizProvider = QuizProvider();

    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a question prompt')));
      return null;
    }
    for (final answer in answers) {
      if (answer.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter all answers')));
        return null;
      }
    }

    try {
      if (widget.question != null) {
        return quizProvider.updateQuestion(
            widget.quizID, widget.question!.id, prompt, answers);
      } else {
        return quizProvider.addQuestion(widget.quizID, prompt, answers);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save question')));
      return null;
    }
  }
}
