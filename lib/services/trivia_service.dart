import 'dart:convert';
import 'package:http/http.dart' as http;

class TriviaService {
  static const String _apiKey = 'qa_sk_2bfb3b86de010358d1771f0898e7de446a429c78';

  static Future<List<dynamic>> fetchQuestions() async {
    final url = Uri.parse(
      'https://quizapi.io/api/v1/questions?limit=10&difficulty=EASY&type=MULTIPLE_CHOICE&random=true',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $_apiKey',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      return data; // QuizAPI returns list directly
    } else {
      throw Exception('Failed to load questions');
    }
  }
}