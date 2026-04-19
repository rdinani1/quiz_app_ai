import 'package:flutter/material.dart';
import 'services/trivia_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: QuizTestScreen(),
    );
  }
}

class QuizTestScreen extends StatefulWidget {
  const QuizTestScreen({super.key});

  @override
  State<QuizTestScreen> createState() => _QuizTestScreenState();
}

class _QuizTestScreenState extends State<QuizTestScreen> {
  List questions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  void loadQuestions() async {
    try {
      final data = await TriviaService.fetchQuestions();
      setState(() {
        questions = data;
        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz API Test')),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(questions[index]['question'] ?? 'No question'),
          );
        },
      ),
    );
  }
}