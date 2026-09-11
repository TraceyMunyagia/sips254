import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../../data/models/bartender_models.dart';

class BartenderRepository {
  String get _baseUrl => dotenv.env['AI_SERVICE_URL'] ?? 'http://localhost:8000';

  Future<BartenderResult> getSuggestionsFromIngredients({
    required List<String> ingredients,
    List<String> spirits = const [],
    Map<String, dynamic>? preferences,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/bartender/ingredients'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'ingredients': ingredients,
        'spirits': spirits,
        'preferences': ?preferences,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('AI Bartender request failed: ${response.statusCode} ${response.body}');
    }

    return BartenderResult.fromMap(jsonDecode(response.body) as Map<String, dynamic>);
  }
}