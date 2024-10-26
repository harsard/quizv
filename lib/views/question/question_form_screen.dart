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
  final Question? question; // Optional question for editing

  const QuestionFormScreen({Key? key, required this.quizID, this.question})
      : super(key: key);

  @override
  _QuestionFormScreenState createState() => _QuestionFormScreenState();
}

class _QuestionFormScreenState extends State<QuestionFormScreen> {
  int answerCount = 1; // Initial number of answers
  String prompt = ''; // Question prompt
  List<Answer> answers = []; // List of answers

  @override
  void initState() {
    super.initState();
    // Initialize prompt and answers if editing
    answerCount = widget.question != null ? widget.question!.answers.length + 1 : 1;
    prompt = widget.question?.questionText ?? '';
    answers = widget.question?.answers ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController promptController =
    TextEditingController(text: prompt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Form'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Question prompt input
            TextFormField(
              controller: promptController,
              onChanged: (value) => prompt = value,
              decoration: const InputDecoration(
                labelText: 'Question Text',
                hintText: 'Enter the question prompt',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Answers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: _answerListBuilder(),
            ),
            const SizedBox(height: 16.0),
            // Save Question button
            ElevatedButton(
              onPressed: _saveQuestion,
              child: const Text('Save Question'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builds the list of answers
  Widget _answerListBuilder() {
    return ListView.builder(
      itemCount: answerCount,
      itemBuilder: (context, index) {
        // If it's the last item, show the Add Answer option
        if (index == answerCount - 1) {
          return Card(
            elevation: 2,
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

  // Builds each individual answer tile
  Widget _answerTileBuilder(int index) {
    // Add a new answer object if needed
    if (answerCount - 1 > answers.length) {
      answers.add(Answer(correct: false, text: ''));
    }

    final TextEditingController answerController =
    TextEditingController(text: answers[index].text);

    return Card(
      elevation: 2,
      child: ListTile(
        title: TextFormField(
          controller: answerController,
          onChanged: (value) {
            answers[index] = Answer(correct: answers[index].correct, text: value);
          },
          decoration: const InputDecoration(
            labelText: 'Answer Text',
            hintText: 'Enter the answer text',
            border: OutlineInputBorder(),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: answers[index].correct,
              onChanged: (value) {
                setState(() {
                  answers[index] = Answer(correct: value, text: answers[index].text);
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  answerCount--;
                  answers.removeAt(index);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // Handles saving the question
  Future<void> _saveQuestion() async {
    QuizProvider quizProvider = QuizProvider();

    // Input validation
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a question prompt')));
      return;
    }
    for (final answer in answers) {
      if (answer.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter all answers')));
        return;
      }
    }

    try {
      Quiz? tmpQuiz;
      if (widget.question != null) {
        tmpQuiz = await quizProvider.updateQuestion(
            widget.quizID, widget.question!.id, prompt, answers);
      } else {
        tmpQuiz = await quizProvider.addQuestion(widget.quizID, prompt, answers);
      }

      // Notify user of success
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Question Saved')));
      Navigator.pop(context, tmpQuiz);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save question')));
    }
  }
}
