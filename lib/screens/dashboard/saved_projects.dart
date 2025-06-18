import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/theme_provider.dart';
import 'ProjectDetailScreen.dart';

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

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: isDarkMode ? backgroundDark : backgroundLight,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: _isScrolled ? 4 : 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Saved Projects',
          style: TextStyle(
            color: Colors.white,
            fontSize: isLargeScreen ? 24 : 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
      body: user == null
          ? Center(
        child: Text(
          'Please log in to view your saved projects.',
          style: TextStyle(color: textColor),
        ),
      )
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('articles')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open,
                      size: isLargeScreen ? 100 : 70,
                      color: textColor.withOpacity(0.5)),
                  const SizedBox(height: 20),
                  Text(
                    'No projects saved yet!',
                    style: TextStyle(
                        fontSize: isLargeScreen ? 20 : 16,
                        color: textColor.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Use tools like AI Writer to save your work.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: isLargeScreen ? 16 : 14,
                        color: textColor.withOpacity(0.5)),
                  ),
                ],
              ),
            );
          }

          final projects = snapshot.data!.docs;

          return ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(isLargeScreen ? 20 : 12),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final data =
              projects[index].data() as Map<String, dynamic>;
              final keyword = data['keyword'] ?? 'Untitled Project';
              final content = data['content'] ?? '';
              final timestamp = data['createdAt'] as Timestamp?;
              final dateStr = timestamp != null
                  ? '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}'
                  : 'Unknown Date';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProjectDetailScreen(
                        keyword: keyword,
                        content: content,
                        date: dateStr,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: EdgeInsets.all(isLargeScreen ? 18 : 14),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: primaryColor.withOpacity(0.15),
                        child: Icon(Icons.edit, color: primaryColor),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              keyword,
                              style: TextStyle(
                                fontSize: isLargeScreen ? 18 : 16,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              dateStr,
                              style: TextStyle(
                                fontSize: isLargeScreen ? 12 : 11,
                                color: textColor.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              content,
                              style: TextStyle(
                                fontSize: isLargeScreen ? 14 : 13,
                                color: textColor.withOpacity(0.9),
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios,
                          size: isLargeScreen ? 20 : 16,
                          color: textColor.withOpacity(0.6)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
