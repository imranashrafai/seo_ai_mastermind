import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../providers/theme_provider.dart';

const primaryColor = Color(0xFF2D5EFF);
const backgroundLight = Color(0xFFF4F7FE);
const backgroundDark = Color(0xFF121212);
const cardLight = Color(0xFFE6EAF3);
const cardDark = Color(0xFF1E1E1E);

class CompetitorAnalyzerScreen extends ConsumerStatefulWidget {
  const CompetitorAnalyzerScreen({super.key});

  @override
  ConsumerState<CompetitorAnalyzerScreen> createState() =>
      _CompetitorAnalyzerScreenState();
}

class _CompetitorAnalyzerScreenState
    extends ConsumerState<CompetitorAnalyzerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _urlController = TextEditingController();
  bool _loading = false;

  int _pageRank = 0;
  int _traffic = 0;
  List<String> _keywords = [];
  List<String> _pages = [];
  List<String> _gaps = [];

  final List<Tab> tabs = [
    const Tab(text: 'Traffic'),
    const Tab(text: 'Keywords'),
    const Tab(text: 'Pages'),
    const Tab(text: 'Gaps'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  Future<void> _analyze() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() => _loading = true);

    try {
      final response = await http.post(
        Uri.parse('https://your-replit-project-url.analyze.repl.co/analyze'), // Replace with your real URL
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'domain': url}),
      );

      final data = json.decode(response.body);
      setState(() {
        _pageRank = data['pageRank'] ?? 0;
        _traffic = data['traffic'] ?? 0;
        _keywords = List<String>.from(data['keywords'] ?? []);
        _pages = List<String>.from(data['pages'] ?? []);
        _gaps = List<String>.from(data['gaps'] ?? []);
        _loading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    super.dispose();
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
        title: const Text('Competitor Analyzer'),
        backgroundColor: isDarkMode ? backgroundDark : primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: isLargeScreen ? 22 : 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _urlController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'Enter Competitor Domain',
                  labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _analyze,
                icon: const Icon(Icons.analytics),
                label: _loading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Text('Analyze Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isLargeScreen ? 16 : 12),
                  textStyle: TextStyle(fontSize: isLargeScreen ? 18 : 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_traffic > 0) _buildResults(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(bool isDarkMode) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PageRank: $_pageRank', style: TextStyle(fontSize: 16, color: textColor)),
        Text('Estimated Monthly Traffic: $_traffic', style: TextStyle(fontSize: 16, color: textColor)),
        const SizedBox(height: 16),
        TabBar(
          controller: _tabController,
          tabs: tabs,
          labelColor: primaryColor,
          unselectedLabelColor: textColor.withOpacity(0.6),
          indicatorColor: primaryColor,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 300,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTrafficTab(),
              _buildListView(_keywords),
              _buildListView(_pages),
              _buildListView(_gaps),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrafficTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Page Rank: $_pageRank",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text("Traffic: $_traffic", style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildListView(List<String> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, index) => ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.green),
        title: Text(items[index]),
      ),
    );
  }
}
