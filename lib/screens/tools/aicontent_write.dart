import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../providers/theme_provider.dart';

// --- Color Scheme ---
const primaryColor = Color(0xFF2D5EFF);
const backgroundLight = Color(0xFFF4F7FE);
const backgroundDark = Color(0xFF121212);
const cardLight = Color(0xFFE6EAF3);
const cardDark = Color(0xFF1E1E1E);
// ---------------------

class AiContentWriterScreen extends ConsumerStatefulWidget {
  const AiContentWriterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AiContentWriterScreen> createState() =>
      _AiContentWriterScreenState();
}

class _AiContentWriterScreenState extends ConsumerState<AiContentWriterScreen> {
  final TextEditingController _keywordController = TextEditingController();
  String? generatedContent;
  bool isLoading = false;

  // ❗ Replace with your own securely stored key in production
  static const String openAIApiKey = dotenv.env['OPENAI_API_KEY'];

  Future<void> _generateContent() async {
    final keywords = _keywordController.text.trim();
    if (keywords.isEmpty) return;

    setState(() {
      isLoading = true;
      generatedContent = null;
    });

    const url = 'https://api.openai.com/v1/chat/completions';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $openAIApiKey',
    };

    final body = jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {
          'role': 'user',
          'content': '''
You are a professional SEO content writer. Write a well-structured, informative, and SEO-optimized article on the topic: "$keywords".

Instructions:
- Article length: Between 150 and 200 words.
- Use clear headings (H2) and short paragraphs.
- Include relevant keywords naturally.
- Start with a compelling introduction, and end with a brief conclusion.
- Avoid fluff and make content valuable to readers.
- Do not mention that you are an AI or chatbot.

Format:
1. Title
2. Introduction
3. Subheadings with meaningful content
4. Conclusion
'''
        }
      ],
      'temperature': 0.7,
      'max_tokens': 270,
    });


    int retry = 0;
    int backoff = 2;

    while (retry < 3) {
      try {
        final res = await http.post(Uri.parse(url), headers: headers, body: body);

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          setState(() {
            generatedContent = data['choices'][0]['message']['content'];
            isLoading = false;
          });
          return;
        }

        if (res.statusCode == 429) {
          retry++;
          await Future.delayed(Duration(seconds: backoff));
          backoff *= 2;
          continue;
        }

        setState(() {
          generatedContent = 'Failed (status ${res.statusCode}).';
          isLoading = false;
        });
        return;
      } catch (_) {
        setState(() {
          generatedContent = 'Network error. Please try again.';
          isLoading = false;
        });
        return;
      }
    }

    setState(() {
      generatedContent = 'Quota exceeded. Please try later.';
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final media = MediaQuery.of(context).size;
    final isLarge = media.width >= 600;

    final bg = isDarkMode ? backgroundDark : backgroundLight;
    final card = isDarkMode ? cardDark : cardLight;
    final txt = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDarkMode ? backgroundDark : primaryColor,
        title: const Text('AI Content Writer'),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: isLarge ? 22 : 18,
        ),
      ),
      body: Padding(
        padding:
        EdgeInsets.symmetric(horizontal: isLarge ? 32 : 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Keyword(s)',
              style: TextStyle(
                fontSize: isLarge ? 20 : 16,
                fontWeight: FontWeight.bold,
                color: txt,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _keywordController,
                maxLines: 3,
                style: TextStyle(color: txt),
                decoration: InputDecoration(
                  hintText: 'e.g., SEO optimization, digital marketing',
                  hintStyle: TextStyle(color: txt.withOpacity(0.5)),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: isLoading
                    ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.auto_fix_high),
                label: const Text('Generate Article'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                  EdgeInsets.symmetric(vertical: isLarge ? 16 : 12),
                  textStyle:
                  TextStyle(fontSize: isLarge ? 18 : 16, fontWeight: FontWeight.w600),
                ),
                onPressed: isLoading ? null : _generateContent,
              ),
            ),
            const SizedBox(height: 30),
            if (isLoading) const Center(child: CircularProgressIndicator()),
            if (generatedContent != null)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generated Article',
                      style: TextStyle(
                        fontSize: isLarge ? 20 : 16,
                        fontWeight: FontWeight.bold,
                        color: txt,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: card,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            generatedContent!,
                            style: TextStyle(color: txt, fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy'),
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: generatedContent!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Article copied to clipboard')),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
