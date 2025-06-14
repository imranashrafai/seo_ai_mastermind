import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChatGPTService {
  final _apiKey = dotenv.env['OPENAI_API_KEY'];
  final String _endpoint = "https://api.openai.com/v1/chat/completions";

  Future<String> askChatGPT(String prompt, List<Map<String, String>> history) async {
    final messages = [
      {"role": "system", "content": "You are SEO AI Mastermind, an expert in search engine optimization. Help users analyze keywords, generate content ideas, improve SEO strategy, and answer with helpful and clear guidance."},
      ...history,
      {"role": "user", "content": prompt},
    ];

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        "Authorization": "Bearer $_apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": messages,
        "temperature": 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].trim();
    } else {
      throw Exception("ChatGPT Error: ${response.body}");
    }
  }
}
