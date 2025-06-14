import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userStatsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, uid) async {
  final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
  if (doc.exists) {
    return {
      'keywordsCount': doc.data()?['keywordsCount'] ?? 0,
      'articlesCount': doc.data()?['articlesCount'] ?? 0,
      'savedProjectsCount': doc.data()?['savedProjectsCount'] ?? 0,
    };
  } else {
    throw Exception('User data not found');
  }
});
