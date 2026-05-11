import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../data/models/reel_model.dart';
import '../data/repositories/reel_repository.dart';
import '../services/video_cache_service.dart';
import '../core/constants/app_constants.dart';

class ReelsController extends GetxController {
  final ReelRepository _reelRepository = ReelRepository();
  final VideoCacheService _cacheService = VideoCacheService();

  // Observable variables
  final RxList<Reel> reels = <Reel>[].obs;
  final Rx<Reel?> currentReel = Rx<Reel?>(null);
  final RxInt currentIndex = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isPlaying = false.obs;
  final RxString errorMessage = ''.obs;

  // Video player controllers
  final Map<String, VideoPlayerController> _videoControllers = {};
  final Map<String, Future<void>> _preloadTasks = {};
  final RxMap<String, bool> videoPreloadStatus = <String, bool>{}.obs;
  final RxMap<String, bool> videoPlaybackStatus = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadReels();
  }

  // Load reels from Firestore
  Future<void> loadReels() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Check cache first
      if (!_cacheService.isCacheExpired(
        expirationHours: AppConstants.videoCacheExpireHours,
      )) {
        final cachedReels = _cacheService.getCachedReels();
        if (cachedReels.isNotEmpty) {
          reels.value = cachedReels;
          if (reels.isNotEmpty) {
            _prepareInitialPlayback();
            return;
          }
        }
      }

      // Fetch from Firestore
      final fetchedReels = await _reelRepository.getReels();
      reels.value = fetchedReels;

      // Cache the reels
      await _cacheService.cacheReels(fetchedReels);

      if (reels.isNotEmpty) {
        _prepareInitialPlayback();
      }
    } catch (e) {
      errorMessage.value = 'Error loading reels: $e';
      debugPrint('Error in loadReels: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _prepareInitialPlayback() {
    currentReel.value = reels[0];
    currentIndex.value = 0;
    preloadVideos();
    Future<void>.delayed(Duration.zero, () {
      if (reels.isNotEmpty && currentIndex.value == 0) {
        playVideo(0);
      }
    });
  }

  // Preload 3-4 videos ahead for seamless playback
  void preloadVideos() {
    int endIndex = (currentIndex.value + AppConstants.preloadCount).clamp(
      0,
      reels.length - 1,
    );

    // Preload current and next videos
    for (int i = currentIndex.value; i <= endIndex; i++) {
      if (i < reels.length) {
        _preloadVideo(i);
      }
    }

    // Cleanup: Dispose videos that are too far behind to save memory
    _cleanupOldVideos();
  }

  // Cleanup video controllers that are too far from current position
  void _cleanupOldVideos() {
    final keysToRemove = <String>[];
    for (var entry in _videoControllers.entries) {
      final reelIndex = reels.indexWhere((r) => r.id == entry.key);
      // Remove if video is more than 5 positions away
      if (reelIndex != -1 && (reelIndex - currentIndex.value).abs() > 5) {
        keysToRemove.add(entry.key);
      }
    }

    for (var key in keysToRemove) {
      _videoControllers[key]?.dispose();
      _videoControllers.remove(key);
      videoPreloadStatus.remove(key);
      videoPlaybackStatus.remove(key);
    }
  }

  Future<void> _preloadVideo(int index) {
    if (index >= reels.length || index < 0) return Future.value();

    final reel = reels[index];

    if (reel.isYoutubeUrl) {
      // YouTube URLs don't need preloading the same way
      videoPreloadStatus[reel.id] = true;
      return Future.value();
    }

    if (_videoControllers.containsKey(reel.id)) {
      videoPreloadStatus[reel.id] = true;
      return Future.value();
    }

    final existingTask = _preloadTasks[reel.id];
    if (existingTask != null) return existingTask;

    final task = _createCachedVideoController(
      reel,
    ).whenComplete(() => _preloadTasks.remove(reel.id));
    _preloadTasks[reel.id] = task;
    return task;
  }

  Future<void> _createCachedVideoController(Reel reel) async {
    try {
      final cachedFile = await _cacheService.getCachedVideoFile(reel.videoUrl);
      final controller = VideoPlayerController.file(cachedFile);
      await controller.initialize();
      await controller.setLooping(true);

      _videoControllers[reel.id] = controller;
      controller.addListener(() => _handleVideoControllerChanged(reel.id));

      videoPreloadStatus[reel.id] = true;
      debugPrint('Video preloaded: ${reel.id}');
    } catch (e) {
      debugPrint('Error preloading video ${reel.id}: $e');
      videoPreloadStatus[reel.id] = false;
    }
  }

  void _handleVideoControllerChanged(String reelId) {
    final controller = _videoControllers[reelId];
    if (controller == null) return;

    final isPlaying = controller.value.isPlaying;
    if (videoPlaybackStatus[reelId] != isPlaying) {
      videoPlaybackStatus[reelId] = isPlaying;
    }
  }

  // Play video with auto-play on scroll
  Future<void> playVideo(int index) async {
    try {
      if (index < 0 || index >= reels.length) return;

      final previousIndex = currentIndex.value;
      currentIndex.value = index;
      currentReel.value = reels[index];

      // Pause previous video
      if (previousIndex >= 0 &&
          previousIndex < reels.length &&
          previousIndex != index) {
        await pauseVideo(reels[previousIndex].id);
      }

      // Preload current and upcoming videos
      await _preloadVideo(index);
      preloadVideos();

      final reel = reels[index];
      if (!reel.isYoutubeUrl && _videoControllers.containsKey(reel.id)) {
        final controller = _videoControllers[reel.id]!;
        await controller.seekTo(Duration.zero);
        await controller.play();
        videoPlaybackStatus[reel.id] = true;
        isPlaying.value = true;
      }

      // Update views
      await _reelRepository.updateReelViews(reel.id, reel.views + 1);
    } catch (e) {
      errorMessage.value = 'Error playing video: $e';
      debugPrint('Error in playVideo: $e');
    }
  }

  // Pause video by reel ID
  Future<void> pauseVideo([String? reelId]) async {
    try {
      final id = reelId ?? currentReel.value?.id;
      if (id != null && _videoControllers.containsKey(id)) {
        await _videoControllers[id]!.pause();
        videoPlaybackStatus[id] = false;
        if (reelId == null || currentReel.value?.id == id) {
          isPlaying.value = false;
        }
      }
    } catch (e) {
      debugPrint('Error pausing video: $e');
    }
  }

  // Resume video
  Future<void> resumeVideo() async {
    try {
      if (currentReel.value != null && !currentReel.value!.isYoutubeUrl) {
        final reel = currentReel.value!;
        final reelIndex = reels.indexWhere((r) => r.id == reel.id);
        if (!_videoControllers.containsKey(reel.id) && reelIndex != -1) {
          await _preloadVideo(reelIndex);
        }

        if (_videoControllers.containsKey(reel.id)) {
          await _videoControllers[reel.id]!.play();
          videoPlaybackStatus[reel.id] = true;
          isPlaying.value = true;
        }
      }
    } catch (e) {
      debugPrint('Error resuming video: $e');
    }
  }

  Future<void> resumeVideoById(String reelId) async {
    final reelIndex = reels.indexWhere((reel) => reel.id == reelId);
    if (reelIndex == -1) return;

    currentIndex.value = reelIndex;
    currentReel.value = reels[reelIndex];
    await resumeVideo();
    preloadVideos();
  }

  // Get video controller
  VideoPlayerController? getVideoController(String reelId) {
    return _videoControllers[reelId];
  }

  // Like/Unlike reel
  Future<void> toggleLike(String reelId) async {
    try {
      final reelIndex = reels.indexWhere((r) => r.id == reelId);
      if (reelIndex != -1) {
        final reel = reels[reelIndex];
        final newLikes = reel.likes + 1;
        await _reelRepository.updateReelLikes(reelId, newLikes);

        final updatedReel = reel.copyWith(likes: newLikes);
        reels[reelIndex] = updatedReel;
        if (currentReel.value?.id == reelId) {
          currentReel.value = updatedReel;
        }

        // Cache the update
        await _cacheService.cacheReel(updatedReel);
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
    }
  }

  // Add new reel
  Future<bool> addNewReel(Reel newReel) async {
    try {
      final reelId = await _reelRepository.addReel(newReel);
      final reelWithId = newReel.copyWith(id: reelId);
      reels.insert(0, reelWithId);
      await _cacheService.cacheReels(reels);
      return true;
    } catch (e) {
      errorMessage.value = 'Error adding reel: $e';
      debugPrint('Error in addNewReel: $e');
      return false;
    }
  }

  // Handle swipe up/down for next/previous video
  Future<void> nextReel() async {
    if (currentIndex.value < reels.length - 1) {
      await playVideo(currentIndex.value + 1);
    }
  }

  Future<void> previousReel() async {
    if (currentIndex.value > 0) {
      await playVideo(currentIndex.value - 1);
    }
  }

  @override
  void onClose() {
    // Clean up video controllers
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    _videoControllers.clear();
    _preloadTasks.clear();
    videoPreloadStatus.clear();
    videoPlaybackStatus.clear();
    super.onClose();
  }
}
