import 'package:http/http.dart' as http;
import 'dart:convert';

/// Fetch keyword suggestions using free APIs: Google Suggest and Datamuse.
/// Returns combined, deduplicated keyword list.
Future<List<String>> fetchKeywordSuggestions(String prompt) async {
  if (prompt.trim().isEmpty) {
    return ['Error: Please enter a valid topic'];
  }

  try {
    final googleKeywords = await _fetchFromGoogle(prompt);
    final datamuseKeywords = await _fetchFromDatamuse(prompt);

    final allKeywords = <String>{
      ...googleKeywords,
      ...datamuseKeywords,
    }.toList();

    if (allKeywords.isEmpty) {
      return ['No keywords found for "$prompt"'];
    }

    return allKeywords;
  } catch (e) {
    return ['Error: ${e.toString()}'];
  }
}

/// Fetch autocomplete suggestions from Google (free, no API key)
Future<List<String>> _fetchFromGoogle(String query) async {
  final url = Uri.parse(
    'https://suggestqueries.google.com/complete/search?client=firefox&q=${Uri.encodeQueryComponent(query)}',
  );

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> suggestions = decoded[1];
      return List<String>.from(suggestions)
          .map((s) => s.toString().trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
  } catch (_) {}
  return [];
}

/// Fetch related terms using Datamuse (free, no API key)
Future<List<String>> _fetchFromDatamuse(String query) async {
  final url = Uri.parse(
    'https://api.datamuse.com/words?ml=${Uri.encodeQueryComponent(query)}&max=15',
  );

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> results = json.decode(response.body);
      return results
          .map((item) => item['word']?.toString() ?? '')
          .where((word) => word.isNotEmpty)
          .toList();
    }
  } catch (_) {}
  return [];
}
