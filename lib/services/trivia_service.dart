import 'dart:convert';
import 'package:http/http.dart' as http;

class TriviaService {
  static const String apiKey = 'YOUR_API_KEY';

  static Future<List<dynamic>> fetchQuestions() async {
    final url = Uri.parse(
      'https://quizapi.io/api/v1/questions?limit=10&difficulty=EASY&type=MULTIPLE_CHOICE&random=true',
    );

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $apiKey'},
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);

      if (body['success'] == true && body['data'] is List) {
        return body['data'];
      }
    }

    throw Exception('Failed to load questions');
  }
}