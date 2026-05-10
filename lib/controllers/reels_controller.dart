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
  final RxMap<String, bool> videoPreloadStatus = <String, bool>{}.obs;

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
      if (!_cacheService.isCacheExpired()) {
        final cachedReels = _cacheService.getCachedReels();
        if (cachedReels.isNotEmpty) {
          reels.value = cachedReels;
          if (reels.isNotEmpty) {
            currentReel.value = reels[0];
            currentIndex.value = 0;
            preloadVideos();
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
        currentReel.value = reels[0];
        currentIndex.value = 0;
        preloadVideos();
      }
    } catch (e) {
      errorMessage.value = 'Error loading reels: $e';
      print('Error in loadReels: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Preload videos ahead
  void preloadVideos() {
    int endIndex = (currentIndex.value + AppConstants.preloadCount)
        .clamp(0, reels.length - 1);
    for (int i = currentIndex.value; i <= endIndex; i++) {
      if (i < reels.length) {
        _preloadVideo(i);
      }
    }
  }

  Future<void> _preloadVideo(int index) async {
    if (index >= reels.length) return;

    final reel = reels[index];

    if (reel.isYoutubeUrl) {
      // YouTube URLs don't need preloading the same way
      videoPreloadStatus[reel.id] = true;
      return;
    }

    try {
      if (!_videoControllers.containsKey(reel.id)) {
        final controller = VideoPlayerController.contentUri(
          Uri.parse(reel.videoUrl),
        );
        await controller.initialize();
        _videoControllers[reel.id] = controller;
        videoPreloadStatus[reel.id] = true;
      }
    } catch (e) {
      print('Error preloading video ${reel.id}: $e');
      videoPreloadStatus[reel.id] = false;
    }
  }

  // Play video
  Future<void> playVideo(int index) async {
    try {
      if (index < 0 || index >= reels.length) return;

      currentIndex.value = index;
      currentReel.value = reels[index];

      await _preloadVideo(index);
      preloadVideos();

      final reel = reels[index];
      if (!reel.isYoutubeUrl && _videoControllers.containsKey(reel.id)) {
        final controller = _videoControllers[reel.id]!;
        await controller.play();
        isPlaying.value = true;
      }

      // Update views
      await _reelRepository.updateReelViews(reel.id, reel.views + 1);
    } catch (e) {
      errorMessage.value = 'Error playing video: $e';
      print('Error in playVideo: $e');
    }
  }

  // Pause video
  Future<void> pauseVideo() async {
    try {
      if (currentReel.value != null && !currentReel.value!.isYoutubeUrl) {
        final reel = currentReel.value!;
        if (_videoControllers.containsKey(reel.id)) {
          await _videoControllers[reel.id]!.pause();
          isPlaying.value = false;
        }
      }
    } catch (e) {
      print('Error pausing video: $e');
    }
  }

  // Resume video
  Future<void> resumeVideo() async {
    try {
      if (currentReel.value != null && !currentReel.value!.isYoutubeUrl) {
        final reel = currentReel.value!;
        if (_videoControllers.containsKey(reel.id)) {
          await _videoControllers[reel.id]!.play();
          isPlaying.value = true;
        }
      }
    } catch (e) {
      print('Error resuming video: $e');
    }
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
      print('Error toggling like: $e');
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
      print('Error in addNewReel: $e');
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
    super.onClose();
  }
}
