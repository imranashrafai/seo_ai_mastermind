import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/keyword_ai_service.dart';

// Your defined primary color
const primaryColor = Color(0xFF2D5EFF);

class KeywordResearchScreen extends StatefulWidget {
  const KeywordResearchScreen({super.key});

  @override
  State<KeywordResearchScreen> createState() => _KeywordResearchScreenState();
}

class _KeywordResearchScreenState extends State<KeywordResearchScreen> {
  final _controller = TextEditingController();
  List<String> keywords = [];
  bool loading = false;

  String selectedCountry = 'Worldwide';
  String selectedIntent = 'Informational';
  String selectedCategory = 'All';

  final countries = ['Worldwide', 'United States', 'India', 'United Kingdom', 'Germany', 'Canada', 'Australia'];
  final intents = ['Informational', 'Navigational', 'Transactional', 'Commercial'];
  final categories = ['All', 'Autos', 'Entertainment', 'Finance', 'Health', 'Sports', 'Technology', 'Travel'];

  Future<void> _generate() async {
    setState(() => loading = true);
    try {
      final prompt =
          '${_controller.text.trim()}, category: $selectedCategory, location: $selectedCountry, intent: $selectedIntent';
      final result = await fetchKeywordSuggestions(prompt);
      setState(() => keywords = result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _exportToCSV() async {
    if (keywords.isEmpty) return;

    final now = DateTime.now();
    final filename = 'keywords_${DateFormat('yyyyMMdd_HHmmss').format(now)}.csv';
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$filename');

    final csvContent = keywords.map((k) => '"$k"').join('\n');
    await file.writeAsString(csvContent);

    await Share.shareXFiles([XFile(file.path)], text: 'Exported SEO Keywords');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          "AI Keyword Research",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          if (keywords.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              tooltip: 'Export CSV',
              onPressed: _exportToCSV,
            ),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Enter Topic or Niche",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedCountry,
                    decoration: const InputDecoration(labelText: "Country"),
                    items: countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => selectedCountry = v ?? 'Worldwide'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedIntent,
                    decoration: const InputDecoration(labelText: "Intent"),
                    items: intents.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
                    onChanged: (v) => setState(() => selectedIntent = v ?? 'Informational'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(labelText: "Category"),
              items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
              onChanged: (v) => setState(() => selectedCategory = v ?? 'All'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: loading
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : const Icon(Icons.search),
              label: const Text("Generate Keywords"),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: loading ? null : _generate,
            ),
            const SizedBox(height: 20),
            if (keywords.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: keywords.length,
                  itemBuilder: (_, i) => ListTile(
                    leading: const Icon(Icons.tag),
                    title: Text(keywords[i]),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: keywords[i]));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Copied "${keywords[i]}"')),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
