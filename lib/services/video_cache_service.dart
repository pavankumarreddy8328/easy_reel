import 'package:easy_reel/data/models/reel_model.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';


class VideoCacheService {
  static const String _reelsCacheKey = 'cached_reels';
  static const String _lastCacheTimeKey = 'cache_time';
  final GetStorage _storage = GetStorage();

  // Cache reels locally
  Future<void> cacheReels(List<Reel> reels) async {
    try {
      final reelsList = reels.map((reel) => reel.toMap()).toList();
      await _storage.write(_reelsCacheKey, jsonEncode(reelsList));
      await _storage.write(_lastCacheTimeKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('Error caching reels: $e');
    }
  }

  // Get cached reels
  List<Reel> getCachedReels() {
    try {
      final cached = _storage.read(_reelsCacheKey);
      if (cached != null) {
        final List<dynamic> reelsList = jsonDecode(cached);
        return reelsList
            .map((reel) => Reel.fromMap(reel as Map<String, dynamic>, reel['id'] ?? ''))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error retrieving cached reels: $e');
      return [];
    }
  }

  // Check if cache is expired
  bool isCacheExpired({int expirationHours = 24}) {
    try {
      final lastCacheTime = _storage.read(_lastCacheTimeKey);
      if (lastCacheTime == null) return true;

      final lastTime = DateTime.parse(lastCacheTime);
      final now = DateTime.now();
      final difference = now.difference(lastTime).inHours;

      return difference > expirationHours;
    } catch (e) {
      print('Error checking cache expiration: $e');
      return true;
    }
  }

  // Clear cache
  Future<void> clearCache() async {
    try {
      await _storage.remove(_reelsCacheKey);
      await _storage.remove(_lastCacheTimeKey);
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  // Cache a specific reel
  Future<void> cacheReel(Reel reel) async {
    try {
      final List<Reel> cachedReels = getCachedReels();
      final index = cachedReels.indexWhere((r) => r.id == reel.id);

      if (index != -1) {
        cachedReels[index] = reel;
      } else {
        cachedReels.add(reel);
      }

      await cacheReels(cachedReels);
    } catch (e) {
      print('Error caching single reel: $e');
    }
  }

  // Get reel from cache by ID
  Reel? getCachedReelById(String id) {
    try {
      final cachedReels = getCachedReels();
      return cachedReels.firstWhere((reel) => reel.id == id);
    } catch (e) {
      return null;
    }
  }
}
