import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../controllers/reels_controller.dart';
import '../routes/app_pages.dart';
import '../data/models/reel_model.dart';

class ReelsView extends GetView<ReelsController> {
  const ReelsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (controller.isLoading.value && controller.reels.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (controller.reels.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.videocam_off, color: Colors.white, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'No reels available',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.toNamed(AppRoutes.addReel),
                  child: const Text('Add First Reel'),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            // Video Feed with smart preloading
            PageView.builder(
              scrollDirection: Axis.vertical,
              onPageChanged: (index) {
                // Auto-play new page and pause old one
                controller.playVideo(index);
              },
              itemCount: controller.reels.length,
              itemBuilder: (context, index) {
                return Obx(() {
                  final isActive = controller.currentIndex.value == index;
                  return ReelCard(
                    key: ValueKey(controller.reels[index].id),
                    reel: controller.reels[index],
                    controller: controller,
                    isActive: isActive,
                  );
                });
              },
            ),

            // Error message
            Obx(() {
              if (controller.errorMessage.value.isNotEmpty) {
                return Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      controller.errorMessage.value,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            // Add Reel FAB
            Positioned(
              bottom: 24,
              right: 24,
              child: FloatingActionButton(
                backgroundColor: Colors.red,
                onPressed: () => Get.toNamed(AppRoutes.addReel),
                child: const Icon(Icons.add),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class ReelCard extends StatefulWidget {
  final Reel reel;
  final ReelsController controller;
  final bool isActive;

  const ReelCard({
    super.key,
    required this.reel,
    required this.controller,
    required this.isActive,
  });

  @override
  State<ReelCard> createState() => _ReelCardState();
}

class _ReelCardState extends State<ReelCard> with WidgetsBindingObserver {
  YoutubePlayerController? _youtubeController;
  bool _isYoutubeUrl = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isYoutubeUrl = widget.reel.isYoutubeUrl;

    if (_isYoutubeUrl) {
      final videoId = YoutubePlayer.convertUrlToId(widget.reel.videoUrl);
      if (videoId != null) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: YoutubePlayerFlags(
            autoPlay: widget.isActive,
            mute: false,
            showLiveFullscreenButton: false,
          ),
        );
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.isActive) return;

      if (_isYoutubeUrl) {
        _youtubeController?.play();
      } else {
        widget.controller.resumeVideoById(widget.reel.id);
      }
    });
  }

  @override
  void didUpdateWidget(ReelCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle visibility change (auto-pause/play)
    if (oldWidget.isActive && !widget.isActive) {
      if (_isYoutubeUrl) {
        _youtubeController?.pause();
      } else {
        widget.controller.pauseVideo(widget.reel.id);
      }
    } else if (!oldWidget.isActive && widget.isActive) {
      if (_isYoutubeUrl) {
        _youtubeController?.play();
      } else {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && widget.isActive) {
            widget.controller.resumeVideo();
          }
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_isYoutubeUrl) {
        _youtubeController?.pause();
      } else {
        widget.controller.pauseVideo(widget.reel.id);
      }
    } else if (state == AppLifecycleState.resumed && widget.isActive) {
      if (_isYoutubeUrl) {
        _youtubeController?.play();
      } else {
        widget.controller.resumeVideo();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_isYoutubeUrl) {
      _youtubeController?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video Player
        _isYoutubeUrl ? _buildYoutubePlayer() : _buildVideoPlayer(),

        // Gradient overlay for better text visibility
        IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withAlpha(100),
                  Colors.black.withAlpha(200),
                ],
              ),
            ),
          ),
        ),

        // UI Elements
        Positioned(bottom: 0, left: 0, right: 0, child: _buildReelInfo()),

        // Top controls
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Easy Reel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Get.back(),
              ),
            ],
          ),
        ),

        // Right side actions
        Positioned(right: 12, bottom: 100, child: _buildActionButtons()),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    return GestureDetector(
      onTap: () {
        final controller = widget.controller.getVideoController(widget.reel.id);
        if (controller != null) {
          if (controller.value.isPlaying) {
            widget.controller.pauseVideo(widget.reel.id);
          } else {
            widget.controller.resumeVideoById(widget.reel.id);
          }
        }
      },
      child: Container(
        color: Colors.black,
        child: Obx(() {
          final isPreloaded =
              widget.controller.videoPreloadStatus[widget.reel.id] ?? false;
          final videoController = widget.controller.getVideoController(
            widget.reel.id,
          );

          if (videoController != null && videoController.value.isInitialized) {
            final isPlaying =
                widget.controller.videoPlaybackStatus[widget.reel.id] ??
                videoController.value.isPlaying;

            return Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: videoController.value.aspectRatio,
                    child: VideoPlayer(videoController),
                  ),
                ),
                if (!isPlaying)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(150),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
              ],
            );
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Colors.white,
                  value: isPreloaded ? null : 0.3,
                ),
                const SizedBox(height: 16),
                Text(
                  isPreloaded ? 'Loading...' : 'Preloading video...',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildYoutubePlayer() {
    final youtubeController = _youtubeController;
    if (youtubeController == null) {
      return const Center(
        child: Icon(Icons.error_outline, color: Colors.white, size: 48),
      );
    }

    return YoutubePlayer(
      controller: youtubeController,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.red,
      progressColors: const ProgressBarColors(
        playedColor: Colors.red,
        handleColor: Colors.redAccent,
      ),
    );
  }

  Widget _buildReelInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Username
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[700],
                child: Text(
                  widget.reel.username.isNotEmpty
                      ? widget.reel.username[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.reel.username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Follow',
                      style: TextStyle(color: Colors.grey[300], fontSize: 12),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  'Follow',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Description
          if (widget.reel.description.isNotEmpty)
            Text(
              widget.reel.description,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Obx(() {
      // Find the current reel in the controller's list to get reactive updates
      final reel =
          widget.controller.reels.firstWhereOrNull(
            (r) => r.id == widget.reel.id,
          ) ??
          widget.reel;

      final isLiked = reel.likes > 0;

      return Column(
        children: [
          // Like Button
          GestureDetector(
            onTap: () => widget.controller.toggleLike(reel.id),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(100),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_outline,
                    color: isLiked ? Colors.red : Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  reel.likes.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Comment Button
          GestureDetector(
            onTap: () {},
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(100),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.message_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '0',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Share Button
          GestureDetector(
            onTap: () {},
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(100),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.share_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Share',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Views
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(100),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.remove_red_eye_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                reel.views.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}
