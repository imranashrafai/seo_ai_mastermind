import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';

const primaryColor = Color(0xFF2D5EFF);
const backgroundLight = Color(0xFFF4F7FE);
const backgroundDark = Color(0xFF121212);
const cardLight = Color(0xFFE6EAF3);
const cardDark = Color(0xFF1E1E1E);

class SeoAnalyzerScreen extends ConsumerStatefulWidget {
  const SeoAnalyzerScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SeoAnalyzerScreen> createState() => _SeoAnalyzerScreenState();
}

class _SeoAnalyzerScreenState extends ConsumerState<SeoAnalyzerScreen> {
  final TextEditingController _contentController = TextEditingController();
  Map<String, String> analysisResult = {};
  bool isLoading = false;

  void _analyzeSeo() {
    final content = _contentController.text.trim();
    if (content.isEmpty) return;

    setState(() {
      isLoading = true;
      analysisResult.clear();
    });

    // Simulated SEO logic
    final wordCount = content.split(RegExp(r'\s+')).length;
    final keyword = content.split(' ').first.toLowerCase();
    final keywordDensity = (RegExp('\\b$keyword\\b', caseSensitive: false)
        .allMatches(content)
        .length /
        wordCount *
        100)
        .toStringAsFixed(2);

    setState(() {
      analysisResult = {
        "Word Count": wordCount.toString(),
        "Focus Keyword": keyword,
        "Keyword Density": "$keywordDensity%",
        "Title Length": content.length >= 60 && content.length <= 70
            ? "Optimal"
            : "Needs adjustment",
      };
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 600;

    final backgroundColor = isDarkMode ? backgroundDark : backgroundLight;
    final cardColor = isDarkMode ? cardDark : cardLight;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: isDarkMode ? backgroundDark : primaryColor,
        title: const Text("SEO Analyzer"),
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.white),
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: isLargeScreen ? 22 : 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 32 : 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter Article or Meta Description",
              style: TextStyle(
                fontSize: isLargeScreen ? 20 : 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _contentController,
                maxLines: 5,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: "Paste article content or description here",
                  hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _analyzeSeo,
                icon: const Icon(Icons.analytics),
                label: const Text("Analyze"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isLargeScreen ? 16 : 12),
                  textStyle: TextStyle(fontSize: isLargeScreen ? 18 : 16),
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (isLoading) const Center(child: CircularProgressIndicator()),
            if (analysisResult.isNotEmpty)
              Expanded(
                child: ListView(
                  children: analysisResult.entries.map((entry) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            entry.value,
                            style: TextStyle(color: textColor),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
