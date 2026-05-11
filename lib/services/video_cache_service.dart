import 'package:easy_reel/core/constants/app_constants.dart';
import 'package:easy_reel/data/models/reel_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'dart:io';

class VideoCacheService {
  static const String _reelsCacheKey = 'cached_reels';
  static const String _lastCacheTimeKey = 'cache_time';
  static final CacheManager _videoCacheManager = CacheManager(
    Config(
      'easy_reel_video_cache',
      stalePeriod: Duration(hours: AppConstants.videoCacheExpireHours),
      maxNrOfCacheObjects: AppConstants.videoCacheMaxObjects,
    ),
  );

  final GetStorage _storage = GetStorage();

  // Cache reels locally
  Future<void> cacheReels(List<Reel> reels) async {
    try {
      final reelsList = reels.map(_reelToCacheMap).toList();
      await _storage.write(_reelsCacheKey, jsonEncode(reelsList));
      await _storage.write(_lastCacheTimeKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Error caching reels: $e');
    }
  }

  // Get cached reels
  List<Reel> getCachedReels() {
    try {
      final cached = _storage.read(_reelsCacheKey);
      if (cached != null) {
        final List<dynamic> reelsList = jsonDecode(cached);
        return reelsList
            .map((reel) => _reelFromCacheMap(Map<String, dynamic>.from(reel)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error retrieving cached reels: $e');
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
      debugPrint('Error checking cache expiration: $e');
      return true;
    }
  }

  // Clear cache
  Future<void> clearCache() async {
    try {
      await _storage.remove(_reelsCacheKey);
      await _storage.remove(_lastCacheTimeKey);
      await _videoCacheManager.emptyCache();
    } catch (e) {
      debugPrint('Error clearing cache: $e');
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
      debugPrint('Error caching single reel: $e');
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

  // Cache/download a video file and return the local copy.
  Future<File> getCachedVideoFile(String videoUrl) {
    return _videoCacheManager.getSingleFile(videoUrl);
  }

  Future<void> removeCachedVideoFile(String videoUrl) {
    return _videoCacheManager.removeFile(videoUrl);
  }

  Map<String, dynamic> _reelToCacheMap(Reel reel) {
    return {
      ...reel.toMap(),
      'id': reel.id,
      'createdAt': reel.createdAt.toIso8601String(),
    };
  }

  Reel _reelFromCacheMap(Map<String, dynamic> map) {
    final createdAtValue = map['createdAt'];
    final createdAt = createdAtValue is String
        ? DateTime.tryParse(createdAtValue) ?? DateTime.now()
        : DateTime.now();

    return Reel(
      id: map['id'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      username: map['username'] ?? 'Unknown',
      description: map['description'] ?? '',
      likes: map['likes'] ?? 0,
      views: map['views'] ?? 0,
      isYoutubeUrl: map['isYoutubeUrl'] ?? false,
      createdAt: createdAt,
    );
  }
}
