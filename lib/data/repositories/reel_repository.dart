import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/reel_model.dart';
import '../../core/constants/app_constants.dart';

class ReelRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all reels
  Future<List<Reel>> getReels() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.reelsCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) => Reel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      debugPrint('Error fetching reels: $e');
      rethrow;
    }
  }

  // Fetch reels with pagination
  Future<List<Reel>> getReelsWithPagination({
    required int limit,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection(AppConstants.reelsCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final QuerySnapshot snapshot = await query.get();

      return snapshot.docs
          .map(
            (doc) => Reel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      debugPrint('Error fetching reels with pagination: $e');
      rethrow;
    }
  }

  // Add a new reel
  Future<String> addReel(Reel reel) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.reelsCollection)
          .add({...reel.toMap(), 'createdAt': FieldValue.serverTimestamp()});
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding reel: $e');
      rethrow;
    }
  }

  // Update reel likes
  Future<void> updateReelLikes(String reelId, int newLikes) async {
    try {
      await _firestore
          .collection(AppConstants.reelsCollection)
          .doc(reelId)
          .update({'likes': newLikes});
    } catch (e) {
      debugPrint('Error updating likes: $e');
      rethrow;
    }
  }

  // Update reel views
  Future<void> updateReelViews(String reelId, int newViews) async {
    try {
      await _firestore
          .collection(AppConstants.reelsCollection)
          .doc(reelId)
          .update({'views': newViews});
    } catch (e) {
      debugPrint('Error updating views: $e');
      rethrow;
    }
  }

  // Delete reel
  Future<void> deleteReel(String reelId) async {
    try {
      await _firestore
          .collection(AppConstants.reelsCollection)
          .doc(reelId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting reel: $e');
      rethrow;
    }
  }

  // Listen to reels in real-time
  Stream<List<Reel>> streamReels() {
    return _firestore
        .collection(AppConstants.reelsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Reel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
