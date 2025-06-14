import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';

const primaryColor = Color(0xFF2D5EFF);
const cardLight = Color(0xFFE6EAF3);
const cardDark = Color(0xFF1E1E1E);

final aiSuggestionsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return [];

  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('aiSuggestions')
      .get();

  return snapshot.docs.map((doc) => doc.data()).toList();
});

class AiSuggestionsSection extends ConsumerWidget {
  const AiSuggestionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final cardColor = isDarkMode ? cardDark : cardLight;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    final suggestionsAsync = ref.watch(aiSuggestionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Suggestions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        suggestionsAsync.when(
          data: (suggestions) {
            if (suggestions.isEmpty) {
              return Text('No suggestions available.', style: TextStyle(color: textColor));
            }

            return Column(
              children: suggestions.map((suggestion) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildSuggestionCard(
                    title: suggestion['title'] ?? 'Untitled',
                    tag: suggestion['tag'] ?? 'General',
                    subtitle: suggestion['description'] ?? '',
                    cardColor: cardColor,
                    textColor: textColor,
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  Widget _buildSuggestionCard({
    required String title,
    required String tag,
    required String subtitle,
    required Color cardColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                Text(subtitle, style: TextStyle(color: textColor.withOpacity(0.7))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 12)),
          )
        ],
      ),
    );
  }
}
