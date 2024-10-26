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
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQuizzes,
            tooltip: "Refresh",
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, AppRoutes.login.toString());
            },
            tooltip: "Logout",
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[100]!, Colors.blue[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _buildQuizList(_quizzes),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add Quiz",
        onPressed: _addQuiz,
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  Widget _buildQuizList(List<Quiz> quizzes) {
    if (quizzes.isEmpty) {
      return const Center(
        child: Text(
          'No quizzes available.',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
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
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
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
        elevation: 5,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          title: Text(
            quiz.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          subtitle: Text(
            quiz.description,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          onTap: () async {
            Quiz? tmpQuiz = await Navigator.pushNamed(
                context, AppRoutes.quizDetail.toString(), arguments: quiz)
            as Quiz?;
            if (tmpQuiz != null) {
              setState(() {
                _quizzes[_quizzes.indexWhere((element) => element.id == tmpQuiz.id)] = tmpQuiz;
              });
            }
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
        final TextEditingController descriptionController = TextEditingController();

        return AlertDialog(
          title: const Text("Add Quiz", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
          content: SizedBox(
            width: double.maxFinite,
            child: Form(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: const Text("Save",style: TextStyle(color: Colors.white),),
                    onPressed: () {
                      _saveAdd(titleController.text, descriptionController.text);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveAdd(String title, String description) async {
    final quizProvider = QuizProvider();
    try {
      Quiz tmpQuiz = await quizProvider.addQuiz(title, description);
      setState(() {
        _quizzes.add(tmpQuiz);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz added successfully!')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
  }
}
