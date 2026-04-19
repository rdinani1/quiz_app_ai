import 'package:flutter/material.dart';
import '../services/trivia_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List questions = [];
  int currentIndex = 0;
  bool isLoading = true;

  String? selectedAnswer;
  bool answered = false;
  int score = 0;

  List options = [];

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
      setupQuestion();
    });
  }

  void setupQuestion() {
    final q = questions[currentIndex];

    final answers = (q['answers'] as List)
        .where((a) => (a['text'] ?? '').toString().isNotEmpty)
        .toList();

    answers.shuffle();

    options = answers;
    selectedAnswer = null;
    answered = false;
  }

  void selectAnswer(Map option) {
    if (answered) return;

    final isCorrect = option['isCorrect'] == true;

    setState(() {
      selectedAnswer = option['text'];
      answered = true;
      if (isCorrect) score++;
    });

    Future.delayed(const Duration(seconds: 1), nextQuestion);
  }

  void nextQuestion() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        setupQuestion();
      });
    } else {
      showResults();
    }
  }

  void showResults() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Quiz Finished"),
        content: Text("Score: $score / ${questions.length}"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              restartQuiz();
            },
            child: const Text("Restart"),
          )
        ],
      ),
    );
  }

  void restartQuiz() {
    setState(() {
      currentIndex = 0;
      score = 0;
      setupQuestion();
    });
  }

  Color getColor(Map option) {
    if (!answered) return Colors.white;

    if (option['isCorrect'] == true) {
      return Colors.green.shade200;
    }

    if (option['text'] == selectedAnswer) {
      return Colors.red.shade200;
    }

    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final q = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(title: const Text("Quiz App")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Question ${currentIndex + 1}/${questions.length}"),
            const SizedBox(height: 10),
            Text(q['text'] ?? ''),
            const SizedBox(height: 20),

            ...options.map((option) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: getColor(option),
                ),
                onPressed: () => selectAnswer(option),
                child: Text(option['text']),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}