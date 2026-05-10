import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../controllers/reels_controller.dart';
import '../routes/app_pages.dart';
import '../data/models/reel_model.dart';

class ReelsView extends GetView<ReelsController> {
  const ReelsView({Key? key}) : super(key: key);

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
            // Video Feed
            PageView.builder(
              scrollDirection: Axis.vertical,
              onPageChanged: (index) {
                controller.playVideo(index);
              },
              itemCount: controller.reels.length,
              itemBuilder: (context, index) {
                return ReelCard(
                  reel: controller.reels[index],
                  controller: controller,
                );
              },
            ),

            // Error message
            if (controller.errorMessage.isNotEmpty)
              Positioned(
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
              ),

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

  const ReelCard({
    Key? key,
    required this.reel,
    required this.controller,
  }) : super(key: key);

  @override
  State<ReelCard> createState() => _ReelCardState();
}

class _ReelCardState extends State<ReelCard> {
  late YoutubePlayerController _youtubeController;
  bool _isYoutubeUrl = false;

  @override
  void initState() {
    super.initState();
    _isYoutubeUrl = widget.reel.isYoutubeUrl;
    
    if (_isYoutubeUrl) {
      final videoId = YoutubePlayer.convertUrlToId(widget.reel.videoUrl);
      if (videoId != null) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
            showLiveFullscreenButton: false,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    if (_isYoutubeUrl) {
      _youtubeController.dispose();
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
        Container(
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

        // UI Elements
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildReelInfo(),
        ),

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
        Positioned(
          right: 12,
          bottom: 100,
          child: _buildActionButtons(),
        ),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    return GestureDetector(
      onTap: () {
        final controller = widget.controller.getVideoController(widget.reel.id);
        if (controller != null) {
          if (controller.value.isPlaying) {
            widget.controller.pauseVideo();
          } else {
            widget.controller.resumeVideo();
          }
        }
      },
      child: Container(
        color: Colors.black,
        child: Obx(() {
          final videoController =
              widget.controller.getVideoController(widget.reel.id);
          if (videoController != null && videoController.value.isInitialized) {
            return Center(
              child: AspectRatio(
                aspectRatio: videoController.value.aspectRatio,
                child: VideoPlayer(videoController),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }),
      ),
    );
  }

  Widget _buildYoutubePlayer() {
    return YoutubePlayer(
      controller: _youtubeController,
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
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 12,
                      ),
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Like Button
        Obx(() {
          final isLiked = false; // You can add liked state management
          return GestureDetector(
            onTap: () => widget.controller.toggleLike(widget.reel.id),
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
                  widget.reel.likes.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }),
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
              widget.reel.views.toString(),
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
  }
}
