import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import 'package:seo_ai_mastermind/screens/profile/profile_screen.dart';
import 'package:seo_ai_mastermind/screens/dashboard/ai_suggestions_section.dart';
import 'package:seo_ai_mastermind/screens/dashboard/user_stats_provider.dart';
import 'package:seo_ai_mastermind/screens/tools/keyword_research_screen.dart';
import 'package:seo_ai_mastermind/screens/subscription/go_premium_screen.dart';
import 'package:seo_ai_mastermind/screens/tools/aicontent_write.dart';
import 'package:seo_ai_mastermind/screens/tools/SeoAnalyzerScreen.dart';
import 'package:seo_ai_mastermind/screens/tools/competitor_analysis.dart';
import 'package:seo_ai_mastermind/screens/dashboard/insights.dart';
import 'package:seo_ai_mastermind/screens/dashboard/saved_projects.dart';
import 'package:seo_ai_mastermind/screens/dashboard/settings.dart';
import 'package:seo_ai_mastermind/chatbot/chat.dart';

// --- Color Scheme (DO NOT CHANGE as per user request) ---
const primaryColor = Color(0xFF2D5EFF);
const backgroundLight = Color(0xFFF4F7FE);
const backgroundDark = Color(0xFF121212);
const cardLight = Color(0xFFE6EAF3);
const cardDark = Color(0xFF1E1E1E);
// --- End Color Scheme ---

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  String? userName;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  late final List<Widget> _pageWidgets;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _scrollController.addListener(_onScroll);
    _pageWidgets = [
      _buildDashboardPage(),
      const InsightsScreen(),
      const ChatbotScreen(), // Placeholder for AI Tools screen
      const SavedProjectsScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_selectedIndex == 0) {
      if (_scrollController.offset > 0 && !_isScrolled) {
        setState(() => _isScrolled = true);
      } else if (_scrollController.offset <= 0 && _isScrolled) {
        setState(() => _isScrolled = false);
      }
    }
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = userDoc.data();
      setState(() {
        userName = data?['fullName'] ?? user.displayName ?? user.email?.split('@').first ?? 'Guest';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 600;

    Color appBarBackgroundColor = isDarkMode
        ? backgroundDark
        : (_selectedIndex == 0 && _isScrolled) ? primaryColor : backgroundLight;

    Color appBarContentColor = isDarkMode
        ? Colors.white
        : ((_selectedIndex == 0 && _isScrolled) ? Colors.white : Colors.black87);

    return Scaffold(
      backgroundColor: isDarkMode ? backgroundDark : backgroundLight,
      appBar: AppBar(
        toolbarHeight: _selectedIndex == 0 ? kToolbarHeight * 1.2 : 0,
        automaticallyImplyLeading: false,
        backgroundColor: appBarBackgroundColor,
        elevation: (_selectedIndex == 0 && _isScrolled) ? 4 : 0,
        title: _selectedIndex == 0
            ? Row(
          children: [
            CircleAvatar(
              backgroundColor: primaryColor,
              radius: 18,
              child: Icon(Icons.person, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                'Hi, ${userName ?? '...'}!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isLargeScreen ? 20 : 16,
                  color: appBarContentColor,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        )
            : null,
        actions: _selectedIndex == 0
            ? [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            ),
            tooltip: 'Profile',
            color: appBarContentColor,
          ),
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.brightness_7 : Icons.dark_mode,
              color: appBarContentColor,
            ),
            onPressed: () => themeNotifier.toggleTheme(),
            tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          ),
          const SizedBox(width: 8),
        ]
            : [],
      ),
      body: _pageWidgets[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            _isScrolled = false;
            if (_selectedIndex == 0 && _scrollController.hasClients) {
              _scrollController.jumpTo(0);
            }
          });
        },
        selectedItemColor: primaryColor,
        unselectedItemColor: isDarkMode ? Colors.white70 : Colors.black54,
        backgroundColor: isDarkMode ? backgroundDark : Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Insights'),
          BottomNavigationBarItem(icon: Icon(Icons.bolt), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildDashboardPage() {
    return Consumer(
      builder: (context, ref, _) {
        final isDarkMode = ref.watch(themeProvider);
        final screenWidth = MediaQuery.of(context).size.width;
        final isLargeScreen = screenWidth >= 600;
        final uid = FirebaseAuth.instance.currentUser?.uid;

        if (uid == null) {
          return Center(
            child: Text(
              "User not logged in",
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black87,
                fontSize: 18,
              ),
            ),
          );
        }

        final statsAsync = ref.watch(userStatsProvider(uid));

        return statsAsync.when(
          data: (stats) => _buildDashboardContent(context, isDarkMode, stats, isLargeScreen),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(
              "Error: ${e.toString()}",
              style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDashboardContent(BuildContext context, bool isDarkMode,
      Map<String, dynamic> stats, bool isLargeScreen) {
    final cardColor = isDarkMode ? cardDark : cardLight;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final keywordsCount = stats['keywordsCount']?.toString() ?? '0';
    final articlesCount = stats['articlesCount']?.toString() ?? '0';
    final savedProjectsCount = stats['savedProjectsCount']?.toString() ?? '0';

    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 24 : 16,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Activity',
            style: TextStyle(
              fontSize: isLargeScreen ? 22 : 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          // Activity boxes with equal width and height
          SizedBox(
            height: isLargeScreen ? 120 : 110,
            child: Row(
              children: [
                Expanded(
                  child: _buildActivityBox(
                    context: context,
                    value: keywordsCount,
                    title: 'Keywords',
                    subtext: '1 left',
                    isDarkMode: isDarkMode,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActivityBox(
                    context: context,
                    value: articlesCount,
                    title: 'Articles',
                    subtext: '1 left',
                    isDarkMode: isDarkMode,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActivityBox(
                    context: context,
                    value: savedProjectsCount,
                    title: 'Saved Projects',
                    subtext: '',
                    isDarkMode: isDarkMode,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const AiSuggestionsSection(),
          const SizedBox(height: 20),
          Text(
            'Quick Tools',
            style: TextStyle(
              fontSize: isLargeScreen ? 22 : 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: isLargeScreen ? 4 : 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: isLargeScreen ? 1.2 : 0.9,
            padding: EdgeInsets.zero,
            children: [
              _buildToolCard(
                context: context,
                title: 'Keyword Research',
                subtitle: 'Find high-value keywords',
                icon: Icons.search,
                color: Colors.green,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const KeywordResearchScreen()),
                ),
              ),
              _buildToolCard(
                context: context,
                title: 'AI Content Writer',
                subtitle: 'Generate SEO-rich blogs',
                icon: Icons.edit,
                color: Colors.blue,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AiContentWriterScreen()),
                ),
              ),
              _buildToolCard(
                context: context,
                title: 'SEO Analyzer',
                subtitle: 'Check website ranking',
                icon: Icons.bar_chart,
                color: Colors.orange,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SeoAnalyzerScreen()),
                ),
              ),
              _buildToolCard(
                context: context,
                title: 'Competitor Analysis',
                subtitle: 'Track competitor stats',
                icon: Icons.show_chart,
                color: Colors.purple,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CompetitorAnalyzerScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Upgrade to Premium for more tools',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isLargeScreen ? 16 : 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GoPremiumScreen(isDarkMode: isDarkMode),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primaryColor,
                    shape: const StadiumBorder(),
                    padding: EdgeInsets.symmetric(
                      horizontal: isLargeScreen ? 20 : 12,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    'Upgrade',
                    style: TextStyle(fontSize: isLargeScreen ? 14 : 12),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  Widget _buildActivityBox({
    required BuildContext context,
    required String value,
    required String title,
    required String subtext,
    required bool isDarkMode,
  }) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 600;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? cardDark : cardLight,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(isLargeScreen ? 16 : 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: isLargeScreen ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: isLargeScreen ? 14 : 12,
              color: textColor.withOpacity(0.8),
            ),
          ),
          if (subtext.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtext,
              style: TextStyle(
                fontSize: isLargeScreen ? 12 : 10,
                color: textColor.withOpacity(0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildToolCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? cardDark : cardLight,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color,
              radius: 20,
              child: Icon(icon, size: 20, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: 12,
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}