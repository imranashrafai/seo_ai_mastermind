import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';

// Color Scheme imported for consistency
const primaryColor = Color(0xFF2D5EFF);
const backgroundLight = Color(0xFFF4F7FE);
const backgroundDark = Color(0xFF121212);
const cardLight = Color(0xFFE6EAF3);
const cardDark = Color(0xFF1E1E1E);

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final cardColor = isDarkMode ? cardDark : cardLight;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 600;

    // AppBar background color logic
    Color appBarBackgroundColor = isDarkMode
        ? backgroundDark
        : _isScrolled ? primaryColor : backgroundLight;

    // AppBar content color logic
    Color appBarContentColor = isDarkMode
        ? Colors.white
        : _isScrolled ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: isDarkMode ? backgroundDark : backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appBarContentColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Insights',
          style: TextStyle(
            color: appBarContentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, // This ensures the title is centered
        backgroundColor: appBarBackgroundColor,
        elevation: _isScrolled ? 4 : 0,
        iconTheme: IconThemeData(color: appBarContentColor),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.all(isLargeScreen ? 32.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Overview',
                style: TextStyle(
                  fontSize: isLargeScreen ? 28 : 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: isLargeScreen ? 3 : 2,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: isLargeScreen ? 1.5 : 1.1,
                padding: EdgeInsets.zero,
                children: [
                  _buildInsightCard(
                    title: 'Traffic Growth',
                    value: '+15%',
                    subtitle: 'vs. last month',
                    icon: Icons.trending_up,
                    iconColor: Colors.green,
                    cardColor: cardColor,
                    textColor: textColor,
                    isLargeScreen: isLargeScreen,
                  ),
                  _buildInsightCard(
                    title: 'Ranked Keywords',
                    value: '1,200',
                    subtitle: 'Top 10 positions',
                    icon: Icons.search,
                    iconColor: Colors.orange,
                    cardColor: cardColor,
                    textColor: textColor,
                    isLargeScreen: isLargeScreen,
                  ),
                  if (isLargeScreen)
                    _buildInsightCard(
                      title: 'Content Performance',
                      value: '8.5/10',
                      subtitle: 'Avg. score',
                      icon: Icons.rate_review,
                      iconColor: Colors.blue,
                      cardColor: cardColor,
                      textColor: textColor,
                      isLargeScreen: isLargeScreen,
                    ),
                  _buildInsightCard(
                    title: 'Backlinks Acquired',
                    value: '87',
                    subtitle: 'New this month',
                    icon: Icons.link,
                    iconColor: Colors.purple,
                    cardColor: cardColor,
                    textColor: textColor,
                    isLargeScreen: isLargeScreen,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Recent Reports',
                style: TextStyle(
                  fontSize: isLargeScreen ? 28 : 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              _buildReportListItem(
                title: 'Monthly SEO Performance Report',
                date: 'June 1, 2025',
                icon: Icons.document_scanner,
                cardColor: cardColor,
                textColor: textColor,
                isLargeScreen: isLargeScreen,
              ),
              _buildReportListItem(
                title: 'Competitor Landscape Analysis',
                date: 'May 28, 2025',
                icon: Icons.pie_chart,
                cardColor: cardColor,
                textColor: textColor,
                isLargeScreen: isLargeScreen,
              ),
              _buildReportListItem(
                title: 'Keyword Gap Analysis',
                date: 'May 20, 2025',
                icon: Icons.compare_arrows,
                cardColor: cardColor,
                textColor: textColor,
                isLargeScreen: isLargeScreen,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color cardColor,
    required Color textColor,
    required bool isLargeScreen,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: cardColor,
      child: Padding(
        padding: EdgeInsets.all(isLargeScreen ? 20 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: isLargeScreen ? 20 : 16,
              backgroundColor: iconColor.withOpacity(0.15),
              child: Icon(icon, color: iconColor, size: isLargeScreen ? 24 : 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: isLargeScreen ? 16 : 13,
                fontWeight: FontWeight.w600,
                color: textColor.withOpacity(0.8),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: isLargeScreen ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: isLargeScreen ? 12 : 10,
                color: textColor.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportListItem({
    required String title,
    required String date,
    required IconData icon,
    required Color cardColor,
    required Color textColor,
    required bool isLargeScreen,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: cardColor,
      child: Padding(
        padding: EdgeInsets.all(isLargeScreen ? 16 : 12),
        child: Row(
          children: [
            Icon(icon, color: primaryColor, size: isLargeScreen ? 28 : 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isLargeScreen ? 16 : 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: isLargeScreen ? 12 : 10,
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: textColor.withOpacity(0.6),
              size: isLargeScreen ? 18 : 14,
            ),
          ],
        ),
      ),
    );
  }
}