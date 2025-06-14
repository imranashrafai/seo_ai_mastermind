import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../profile/profile_screen.dart';
import '../subscription/go_premium_screen.dart';

const primaryColor = Color(0xFF2D5EFF);
const backgroundLight = Color(0xFFF4F7FE);
const backgroundDark = Color(0xFF121212);
const cardLight = Color(0xFFE6EAF3);
const cardDark = Color(0xFF1E1E1E);

class ProDashboard extends ConsumerStatefulWidget {
  const ProDashboard({Key? key}) : super(key: key);

  @override
  ConsumerState<ProDashboard> createState() => _ProDashboardState();
}

class _ProDashboardState extends ConsumerState<ProDashboard> {
  int _selectedIndex = 0;
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;

  Map<String, int> _stats = {
    'keywordsCount': 0,
    'articlesCount': 0,
    'savedProjectsCount': 0,
  };

  String _userName = 'Guest';
  bool _isLoading = true;
  bool _isProUser = false; // State variable for pro user status

  static const int keywordsLimit = 10;
  static const int articlesLimit = 10;

  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    _fetchUserDetails();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Method to handle scroll events for app bar background change
  void _onScroll() {
    if (_selectedIndex == 0) { // Only apply this logic to the dashboard tab
      if (_scrollController.offset > 0 && !_isScrolled) {
        setState(() => _isScrolled = true);
      } else if (_scrollController.offset <= 0 && _isScrolled) {
        setState(() => _isScrolled = false);
      }
    }
  }

  Future<void> _fetchUserDetails() async {
    final user = _auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      setState(() {
        _userName = 'Guest';
        _isProUser = false;
        _isLoading = false;
      });
      return;
    }

    try {
      final uid = user.uid;
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!mounted) return;

      if (userDoc.exists) {
        final data = userDoc.data()!;
        setState(() {
          // Prioritize 'fullName' from Firestore, then displayName, then email prefix
          _userName = data['fullName'] ?? user.displayName ?? user.email?.split('@').first ?? 'Guest';
          _isProUser = data['isProUser'] as bool? ?? false; // Fetch isProUser status

          // Also update stats here, as it's part of the user details fetch
          _stats = {
            'keywordsCount': (data['keywordsCount'] as int?) ?? 0,
            'articlesCount': (data['articlesCount'] as int?) ?? 0,
            'savedProjectsCount': (data['savedProjectsCount'] as int?) ?? 0,
          };
          _isLoading = false;
        });
      } else {
        // If user document doesn't exist, use Auth details and assume not pro
        setState(() {
          _userName = user.displayName ?? user.email?.split('@').first ?? 'Guest';
          _isProUser = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      // Log error for debugging, then fallback to Auth details
      print('Error fetching user details: $e');
      setState(() {
        _userName = user.displayName ?? user.email?.split('@').first ?? 'Guest';
        _isProUser = false; // Default to not pro on error
        _isLoading = false;
      });
    }
  }


  // Custom widget for hoverable icon buttons
  Widget _buildHoverableIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required Color iconColor,
    required Color hoverColor, // This will be used
  }) {
    return InkWell(
      onTap: onPressed,
      // Using splashFactory to ensure visual feedback on tap
      splashFactory: InkRipple.splashFactory,
      highlightColor: hoverColor.withOpacity(0.1), // Gentle highlight on press/hold
      hoverColor: hoverColor.withOpacity(0.3), // Stronger hover effect
      customBorder: const CircleBorder(), // Keep the circular shape for hit testing
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Add padding for larger touch target
        child: Icon(icon, color: iconColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 600;

    // Dynamic AppBar background color based on scroll and dark mode
    Color appBarBackgroundColor = isDarkMode
        ? backgroundDark
        : (_selectedIndex == 0 && _isScrolled) ? primaryColor : backgroundLight;

    // Dynamic AppBar content color based on app bar background
    Color appBarContentColor = isDarkMode
        ? Colors.white
        : ((_selectedIndex == 0 && _isScrolled) ? Colors.white : Colors.black87);

    return Scaffold(
      backgroundColor: isDarkMode ? backgroundDark : backgroundLight,
      appBar: AppBar(
        // Dynamic toolbar height based on selected index and scroll state
        toolbarHeight: _selectedIndex == 0 ? kToolbarHeight * 1.2 : kToolbarHeight,
        automaticallyImplyLeading: false, // Ensure no back button appears by default
        backgroundColor: appBarBackgroundColor, // Use dynamic background color
        elevation: (_selectedIndex == 0 && _isScrolled) ? 4 : 0, // Show elevation on scroll
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: primaryColor,
              child: Icon(Icons.person, color: Colors.white), // Icon color on primary
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _isLoading
                  ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
              )
                  : Row( // Use a Row to align username and PRO badge
                mainAxisSize: MainAxisSize.min, // Make row only as wide as its children
                children: [
                  Flexible(
                    child: Text(
                      'Hi, $_userName!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isLargeScreen ? 22 : 18,
                        color: appBarContentColor, // Use dynamic content color
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (_isProUser) // Conditionally display PRO badge
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryColor, // Use primary color for the badge
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'PRO',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isLargeScreen ? 10 : 9,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          _buildHoverableIconButton( // Using the hoverable button
            icon: Icons.person_outline,
            tooltip: 'Profile, $_userName',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            iconColor: appBarContentColor, // Use dynamic content color
            hoverColor: primaryColor, // Pass primaryColor as the base hover color
          ),
          _buildHoverableIconButton( // Using the hoverable button
            icon: isDarkMode ? Icons.brightness_7 : Icons.dark_mode,
            tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () => themeNotifier.toggleTheme(),
            iconColor: appBarContentColor, // Use dynamic content color
            hoverColor: primaryColor, // Pass primaryColor as the base hover color
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _selectedIndex == 0
          ? (_isProUser ? _buildProDashboard(isDarkMode, isLargeScreen) : _buildNotProView(isDarkMode, isLargeScreen))
          : _buildPageForSelectedIndex(isDarkMode, isLargeScreen), // New: Handle other tabs
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            // Reset scroll state when changing tabs to prevent incorrect app bar color
            _isScrolled = false;
            if (_selectedIndex == 0 && _scrollController.hasClients) {
              _scrollController.jumpTo(0); // Scroll to top when returning to dashboard
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
          BottomNavigationBarItem(icon: Icon(Icons.bolt), label: 'AI Tools'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  // Placeholder for other pages, replace with your actual screen widgets
  Widget _buildPageForSelectedIndex(bool isDarkMode, bool isLargeScreen) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    String pageName;
    switch (_selectedIndex) {
      case 1:
        pageName = 'Insights Screen'; // Replace with actual InsightsScreen()
        break;
      case 2:
        pageName = 'AI Tools Screen'; // Replace with actual ChatbotScreen()
        break;
      case 3:
        pageName = 'Saved Projects Screen'; // Replace with actual SavedProjectsScreen()
        break;
      case 4:
        pageName = 'Settings Screen'; // Replace with actual SettingsScreen()
        break;
      default:
        pageName = 'Dashboard Screen'; // Should not happen with _selectedIndex 0
        break;
    }
    return Center(
      child: Text(
        '$pageName (Not Implemented Yet)',
        style: TextStyle(color: textColor, fontSize: 20),
      ),
    );
  }


  Widget _buildProDashboard(bool isDarkMode, bool isLargeScreen) {
    final cardColor = isDarkMode ? cardDark : cardLight;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final horizontalPadding = isLargeScreen ? 40.0 : 16.0;

    final keywordsCount = _stats['keywordsCount'] ?? 0;
    final articlesCount = _stats['articlesCount'] ?? 0;
    final savedProjectsCount = _stats['savedProjectsCount'] ?? 0;

    return SingleChildScrollView(
      controller: _scrollController, // Assign scroll controller here
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Activity',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _buildInfoCard(
                      'Keywords',
                      keywordsCount.toString(),
                      '${(keywordsLimit - keywordsCount).clamp(0, keywordsLimit)} left',
                      cardColor,
                      textColor,
                      isLargeScreen
                  )
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildInfoCard(
                      'Articles',
                      articlesCount.toString(),
                      '${(articlesLimit - articlesCount).clamp(0, articlesLimit)} left',
                      cardColor,
                      textColor,
                      isLargeScreen
                  )
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildInfoCard(
                      'Saved Projects',
                      savedProjectsCount.toString(),
                      '',
                      cardColor,
                      textColor,
                      isLargeScreen
                  )
              ),
            ],
          ),
          const SizedBox(height: 25),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text('AI Suggestions Section (Coming Soon)',
                style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 16)),
          ),
          const SizedBox(height: 30),
          Text('Quick Tools',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: isLargeScreen ? 4 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: isLargeScreen ? 1.3 : 1.0,
            children: [
              _buildToolCard('Keyword Research', 'Find high-value keywords',
                  Colors.green, Icons.add, cardColor, textColor),
              _buildToolCard('AI Content Writer', 'Generate SEO-rich blogs',
                  Colors.blue, Icons.edit, cardColor, textColor),
              _buildToolCard('Article Editor', 'Polish your articles', Colors.purple,
                  Icons.edit_note, cardColor, textColor),
              _buildToolCard('Saved Content', 'Manage your saved items', Colors.orange,
                  Icons.bookmark, cardColor, textColor),
            ],
          ),
          const SizedBox(height: 30),
          Text('Premium Features',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 12),
          _buildPremiumFeaturesList(cardColor, textColor),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String mainInfo, String secondaryInfo,
      Color backgroundColor, Color textColor, bool isLargeScreen) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor.withOpacity(0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  mainInfo,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (secondaryInfo.isNotEmpty) ...[
                const SizedBox(width: 4),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    secondaryInfo,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(String title, String subtitle, Color iconColor,
      IconData iconData, Color backgroundColor, Color textColor) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title tapped (Not Implemented)')),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(iconData, color: iconColor, size: 40),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumFeaturesList(Color backgroundColor, Color textColor) {
    final features = [
      'Unlimited Keywords & Articles',
      'Advanced AI Assistance',
      'Access to Exclusive Templates',
      'Priority Customer Support',
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: features
            .map(
              (feature) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: primaryColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    feature,
                    style: TextStyle(
                      fontSize: 15,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
            .toList(),
      ),
    );
  }

  Widget _buildNotProView(bool isDarkMode, bool isLargeScreen) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: isLargeScreen ? 60 : 24, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, color: primaryColor, size: isLargeScreen ? 60 : 50),
            const SizedBox(height: 20),
            Text(
              'Unlock Pro Features',
              style: TextStyle(
                fontSize: isLargeScreen ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Upgrade to Pro to enjoy unlimited keywords, articles, advanced AI tools, and much more!',
              style: TextStyle(
                fontSize: isLargeScreen ? 16 : 14,
                color: textColor.withOpacity(0.8),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  textStyle: TextStyle(fontSize: isLargeScreen ? 18 : 16, fontWeight: FontWeight.w600)
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GoPremiumScreen(isDarkMode: isDarkMode),
                  ),
                );
              },
              child: const Text(
                'Go Premium',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
