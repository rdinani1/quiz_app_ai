import 'package:flutter/material.dart';
import 'services/trivia_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: TestScreen());
  }
}

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  List questions = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    final data = await TriviaService.fetchQuestions();
    setState(() {
      questions = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const CircularProgressIndicator();

    return Scaffold(
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (_, i) => Text(questions[i]['text']),
      ),
    );
  }
}