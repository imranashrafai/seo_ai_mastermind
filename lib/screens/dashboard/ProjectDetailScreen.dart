import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const primaryColor = Color(0xFF2D5EFF);
const backgroundLight = Color(0xFFF4F7FE);
const backgroundDark = Color(0xFF121212);
const cardLight = Color(0xFFE6EAF3);
const cardDark = Color(0xFF1E1E1E);

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final String keyword;
  final String content;
  final String date;

  const ProjectDetailScreen({
    Key? key,
    required this.keyword,
    required this.content,
    required this.date,
  }) : super(key: key);

  @override
  ConsumerState<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  late TextEditingController _keywordController;
  late TextEditingController _contentController;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _keywordController = TextEditingController(text: widget.keyword);
    _contentController = TextEditingController(text: widget.content);
  }

  @override
  void dispose() {
    _keywordController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('articles')
          .where('keyword', isEqualTo: widget.keyword)
          .where('content', isEqualTo: widget.content)
          .get();

      if (query.docs.isNotEmpty) {
        final docId = query.docs.first.id;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('articles')
            .doc(docId)
            .update({
          'keyword': _keywordController.text.trim(),
          'content': _contentController.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project updated successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $e')),
      );
    }

    setState(() {
      _isSaving = false;
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    final textColor = isDark ? Colors.white : Colors.black87;
    final bgColor = isDark ? backgroundDark : backgroundLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 2,
        title: Text(
          'Project Details',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing)
            IconButton(
              icon: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.save),
              onPressed: _saveChanges,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _keywordController,
              readOnly: !_isEditing,
              decoration: InputDecoration(
                labelText: 'Keyword',
                labelStyle: TextStyle(color: textColor),
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: textColor),
            ),
            const SizedBox(height: 20),

            /// Content with Copy Button at Bottom Right
            Stack(
              children: [
                TextField(
                  controller: _contentController,
                  readOnly: !_isEditing,
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: 'Content',
                    labelStyle: TextStyle(color: textColor),
                    border: OutlineInputBorder(),
                  ),
                  style: TextStyle(color: textColor),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.copy, color: Colors.white),
                      tooltip: "Copy to clipboard",
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _contentController.text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Content copied to clipboard')),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Created on: ${widget.date}',
              style: TextStyle(color: textColor.withOpacity(0.6), fontStyle: FontStyle.italic),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }
}
