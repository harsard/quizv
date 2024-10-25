import 'package:flutter/material.dart';

import '../../constants/app_routes.dart';
import '../../models/quiz.dart';
import '../../providers/quiz_provider.dart';

class QuizListScreen extends StatefulWidget {
  const QuizListScreen({super.key});

  @override
  _QuizListScreenState createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  List<Quiz> _quizzes = [];

  @override
  void initState() {
    print('initState');
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    final quizProvider = QuizProvider();
    await quizProvider.fetchQuizzes();
    setState(() {
      _quizzes = quizProvider.quizzes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQuizzes,
            tooltip: "Refresh",
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(
                  context, AppRoutes.login.toString());
            },
            tooltip: "Logout",
          )
        ],
      ),
      body: _buildQuizList(_quizzes),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add Quiz",
        onPressed: _addQuiz,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuizList(List<Quiz> quizzes) {
    if (quizzes.isEmpty) {
      return const Center(
        child: Text('No quizzes available.'),
      );
    }

    return ListView.builder(
      itemCount: quizzes.length,
      itemBuilder: (context, index) {
        final quiz = quizzes[index];
        return _buildQuizTile(context, quiz);
      },
    );
  }

  Widget _buildQuizTile(BuildContext context, Quiz quiz) {
    return GestureDetector(
      onTapDown: (details) {
        final screenSize = MediaQuery.of(context).size;
        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(
              details.globalPosition.dx,
              details.globalPosition.dy,
              screenSize.width - details.globalPosition.dx,
              screenSize.height - details.globalPosition.dy),
          items: <PopupMenuEntry>[
            PopupMenuItem(
              child: const Row(
                children: <Widget>[
                  Icon(Icons.delete),
                  Text("Delete"),
                ],
              ),
              onTap: () {
                _deleteQuiz(quiz);
              },
            )
          ],
        );
      },
      child: Card(
        child: ListTile(
          title: Text(quiz.title),
          subtitle: Text(quiz.description),
          onTap: () async {
            Quiz tmpQuiz = await Navigator.pushNamed(
                    context, AppRoutes.quizDetail.toString(), arguments: quiz)
                as Quiz;
            setState(
              () {
                _quizzes[_quizzes.indexWhere(
                    (element) => element.id == tmpQuiz.id)] = tmpQuiz;
              },
            );
          },
        ),
      ),
    );
  }

  void _addQuiz() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          final TextEditingController titleController = TextEditingController();
          final TextEditingController descriptionController =
              TextEditingController();

          return AlertDialog(
              content: Stack(
            children: <Widget>[
              const Text("Add Quiz",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Form(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            child: const Text("Save"),
                            onPressed: () {
                              _saveAdd(titleController.text,
                                  descriptionController.text);
                            }))
                  ],
                ),
              ),
            ],
          ));
        });
  }

  Future<void> _saveAdd(String title, String description) async {
    final quizProvider = QuizProvider();
    try {
      Quiz tmpQuiz = await quizProvider.addQuiz(title, description);
      setState(() {
        _quizzes.add(tmpQuiz);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    } finally {
      Navigator.of(context).pop();
    }
  }

  Future<void> _deleteQuiz(Quiz quiz) async {
    final quizProvider = QuizProvider();
    try {
      await quizProvider.deleteQuiz(quiz.id);
      setState(() {
        _quizzes.removeWhere((element) => element.id == quiz.id);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
  }
}
