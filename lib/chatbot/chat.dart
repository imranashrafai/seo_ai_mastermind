import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../providers/theme_provider.dart';
import 'package:seo_ai_mastermind/services/chatbotService.dart';

const primaryColor = Color(0xFF2D5EFF);
const backgroundLight = Color(0xFFF4F7FE);
const backgroundDark = Color(0xFF121212);
const cardLight = Color(0xFFE6EAF3);
const cardDark = Color(0xFF1E1E1E);

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ChatGPTService _apiService = ChatGPTService();
  List<Map<String, dynamic>> chat = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('seo_mastermind_chat');
    if (saved != null) {
      setState(() {
        chat = List<Map<String, dynamic>>.from(jsonDecode(saved));
      });
    }
  }

  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('seo_mastermind_chat', jsonEncode(chat));
  }

  Future<void> sendMessage() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    final timestamp = DateTime.now().toIso8601String();

    setState(() {
      chat.add({'role': 'user', 'msg': input, 'time': timestamp});
      isLoading = true;
      _controller.clear();
    });

    _saveChatHistory();

    try {
      final history = chat.map((e) => {
        'role': e['role'].toString(),
        'content': e['msg'].toString()
      }).toList();
      ;
      final response = await _apiService.askChatGPT(input, history);

      setState(() {
        chat.add({'role': 'assistant', 'msg': response, 'time': DateTime.now().toIso8601String()});
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        chat.add({'role': 'assistant', 'msg': 'Error: $e', 'time': timestamp});
        isLoading = false;
      });
    }

    _saveChatHistory();
  }

  Widget _buildMessage(Map<String, dynamic> entry, bool isDark) {
    final isUser = entry['role'] == 'user';
    final time = DateFormat('hh:mm a').format(DateTime.parse(entry['time']));
    final msg = entry['msg'];

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
            padding: const EdgeInsets.all(12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: isUser
                  ? primaryColor
                  : (isDark ? cardDark : cardLight),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(msg,
                    style: TextStyle(
                      color: isUser ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    )),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      time,
                      style: TextStyle(fontSize: 10, color: isUser ? Colors.white60 : Colors.grey),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 16),
                      color: isUser ? Colors.white60 : Colors.grey,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: msg));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Copied to clipboard')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: isUser ? 0 : 12, right: isUser ? 12 : 0),
            child: Icon(
              isUser ? Icons.person : Icons.smart_toy_rounded,
              color: isUser ? primaryColor : (isDark ? Colors.white70 : primaryColor),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: isDark ? backgroundDark : backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? backgroundDark : primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('SEO AI Mastermind'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: chat.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < chat.length) {
                  return _buildMessage(chat[index], isDark);
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        const CircularProgressIndicator(color: primaryColor, strokeWidth: 2),
                        const SizedBox(width: 10),
                        Text(
                          'SEO AI Mastermind is typing...',
                          style: TextStyle(color: isDark ? Colors.white60 : Colors.black87),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
          Container(
            color: isDark ? cardDark : cardLight,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? backgroundDark : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: primaryColor),
                      ),
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Ask something about SEO...',
                          hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: sendMessage,
                    color: primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
