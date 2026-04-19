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
  bool hasError = false;

  String? selectedAnswer;
  bool answered = false;
  int score = 0;

  List options = [];

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  // 🔥 LOAD QUESTIONS (WITH ERROR HANDLING)
  void loadQuestions() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final data = await TriviaService.fetchQuestions();

      setState(() {
        questions = data;
        isLoading = false;
        setupQuestion();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to load questions. Check your internet."),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // 🔥 SETUP QUESTION
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

  // 🧠 AI HINT FEATURE
  String generateHint(String question) {
    if (question.toLowerCase().contains("python")) {
      return "Think about Python syntax.";
    } else if (question.toLowerCase().contains("docker")) {
      return "Think about containers.";
    }
    return "Try eliminating wrong answers.";
  }

  // 🔥 HANDLE ANSWER
  void selectAnswer(Map option) {
    if (answered) return;

    final isCorrect = option['isCorrect'] == true;

    setState(() {
      selectedAnswer = option['text'];
      answered = true;

      if (isCorrect) score++;
    });

    // ✅ Correct feedback
    if (isCorrect) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Correct!"),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    // 🧠 Hint if wrong
    if (!isCorrect) {
      final hint = generateHint(questions[currentIndex]['text']);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Hint: $hint"),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    Future.delayed(const Duration(seconds: 1), nextQuestion);
  }

  // 🔥 NEXT QUESTION
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

  // 🧠 SMART SUMMARY
  void showResults() {
    double percent = (score / questions.length) * 100;

    String feedback;
    if (percent >= 80) {
      feedback = "🔥 Excellent!";
    } else if (percent >= 50) {
      feedback = "👍 Good job!";
    } else {
      feedback = "📚 Needs improvement.";
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Quiz Finished"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/celebration.png', height: 100),
            const SizedBox(height: 10),
            Text(
              "Score: $score / ${questions.length}\n"
              "${percent.toStringAsFixed(0)}%\n\n$feedback",
              textAlign: TextAlign.center,
            ),
          ],
        ),
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

  // 🎨 COLORS
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
    // 🔄 LOADING SCREEN (IMAGE)
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: Image.asset('assets/images/loading.png', height: 120),
        ),
      );
    }

    // ❌ ERROR SCREEN
    if (hasError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Failed to load questions"),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: loadQuestions,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    final q = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(title: const Text("Quiz App")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Question ${currentIndex + 1}/${questions.length}",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 10),

            // 📊 PROGRESS BAR
            LinearProgressIndicator(
              value: (currentIndex + 1) / questions.length,
            ),

            const SizedBox(height: 20),

            Text(
              q['text'] ?? '',
              style: const TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 20),

            ...options.map((option) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: getColor(option),
                  ),
                  onPressed: () => selectAnswer(option),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(child: Text(option['text'])),

                      // ✔ CORRECT ICON
                      if (answered && option['isCorrect'] == true)
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Image.asset(
                            'assets/icons/correct.png',
                            height: 20,
                          ),
                        ),

                      // ❌ WRONG ICON
                      if (answered &&
                          option['text'] == selectedAnswer &&
                          option['isCorrect'] != true)
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Image.asset(
                            'assets/icons/wrong.png',
                            height: 20,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}