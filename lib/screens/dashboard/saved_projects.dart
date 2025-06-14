import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';

// Color Scheme
const primaryColor = Color(0xFF2D5EFF);
const backgroundLight = Color(0xFFF4F7FE);
const backgroundDark = Color(0xFF121212);
const cardLight = Color(0xFFE6EAF3);
const cardDark = Color(0xFF1E1E1E);

class SavedProjectsScreen extends ConsumerStatefulWidget {
  const SavedProjectsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SavedProjectsScreen> createState() => _SavedProjectsScreenState();
}

class _SavedProjectsScreenState extends ConsumerState<SavedProjectsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  final List<Map<String, String>> _savedProjects = const [
    {
      'title': 'E-commerce Site Keyword Research',
      'date': 'May 25, 2025',
      'type': 'Keyword Research',
    },
    {
      'title': 'Blog Post: "The Future of AI in SEO"',
      'date': 'May 20, 2025',
      'type': 'AI Content',
    },
    {
      'title': 'Competitor Analysis for "TechGadgets"',
      'date': 'May 18, 2025',
      'type': 'Competitor Analysis',
    },
    {
      'title': 'SEO Audit Report: "MyCompany Website"',
      'date': 'May 10, 2025',
      'type': 'SEO Analyzer',
    },
    {
      'title': 'Local SEO Strategy for "Coffee Shop"',
      'date': 'April 30, 2025',
      'type': 'Keyword Research',
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 0 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 0 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Keyword Research':
        return Icons.search;
      case 'AI Content':
        return Icons.edit;
      case 'Competitor Analysis':
        return Icons.show_chart;
      case 'SEO Analyzer':
        return Icons.analytics;
      default:
        return Icons.folder;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final cardColor = isDarkMode ? cardDark : cardLight;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 600;

    // AppBar color logic
    final appBarBgColor = isDarkMode
        ? backgroundDark
        : _isScrolled
        ? primaryColor
        : backgroundLight;

    final appBarContentColor = isDarkMode
        ? Colors.white
        : _isScrolled
        ? Colors.white
        : Colors.black87;

    return Scaffold(
      backgroundColor: isDarkMode ? backgroundDark : backgroundLight,
      appBar: AppBar(
        backgroundColor: appBarBgColor,
        elevation: _isScrolled ? 4 : 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appBarContentColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Saved Projects',
          style: TextStyle(
            color: appBarContentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: appBarContentColor),
      ),
      body: _savedProjects.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: isLargeScreen ? 100 : 70,
              color: textColor.withOpacity(0.5),
            ),
            SizedBox(height: 20),
            Text(
              'No projects saved yet!',
              style: TextStyle(
                fontSize: isLargeScreen ? 20 : 16,
                color: textColor.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Start using our tools to save your work.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isLargeScreen ? 16 : 14,
                color: textColor.withOpacity(0.5),
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(isLargeScreen ? 20.0 : 12.0),
        itemCount: _savedProjects.length,
        itemBuilder: (context, index) {
          final project = _savedProjects[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(isLargeScreen ? 18 : 14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: primaryColor.withOpacity(0.15),
                  child: Icon(
                    _getIconForType(project['type']!),
                    color: primaryColor,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project['title']!,
                        style: TextStyle(
                          fontSize: isLargeScreen ? 18 : 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        project['type']!,
                        style: TextStyle(
                          fontSize: isLargeScreen ? 14 : 12,
                          color: textColor.withOpacity(0.7),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        project['date']!,
                        style: TextStyle(
                          fontSize: isLargeScreen ? 12 : 10,
                          color: textColor.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: textColor.withOpacity(0.6),
                  size: isLargeScreen ? 20 : 16,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
