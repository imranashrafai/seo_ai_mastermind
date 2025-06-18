import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userStatsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, uid) async {
  final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

  final keywordsCount = userDoc.data()?['keywordsCount'] ?? 0;

  // Fetch count from subcollection 'articles'
  final articlesSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('articles')
      .get();
  final articlesCount = articlesSnapshot.size;

  return {
    'keywordsCount': keywordsCount,
    'articlesCount': articlesCount,
    'savedProjectsCount': articlesCount, // reused as saved projects count
  };
});
