import 'package:flutter/material.dart';
import '../services/trivia_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List questions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  void loadQuestions() async {
    final data = await TriviaService.fetchQuestions();
    setState(() {
      questions = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Quiz App")),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (_, i) {
          return ListTile(
            title: Text(questions[i]['text'] ?? ''),
          );
        },
      ),
    );
  }
}