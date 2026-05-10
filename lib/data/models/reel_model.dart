class Reel {
  final String id;
  final String videoUrl;
  final String username;
  final String description;
  final int likes;
  final int views;
  final bool isYoutubeUrl;
  final DateTime createdAt;

  Reel({
    required this.id,
    required this.videoUrl,
    required this.username,
    required this.description,
    required this.likes,
    required this.views,
    this.isYoutubeUrl = false,
    required this.createdAt,
  });

  // Convert from Firestore document
  factory Reel.fromMap(Map<String, dynamic> map, String id) {
    return Reel(
      id: id,
      videoUrl: map['videoUrl'] ?? '',
      username: map['username'] ?? 'Unknown',
      description: map['description'] ?? '',
      likes: map['likes'] ?? 0,
      views: map['views'] ?? 0,
      isYoutubeUrl: map['isYoutubeUrl'] ?? false,
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'videoUrl': videoUrl,
      'username': username,
      'description': description,
      'likes': likes,
      'views': views,
      'isYoutubeUrl': isYoutubeUrl,
      'createdAt': createdAt,
    };
  }

  Reel copyWith({
    String? id,
    String? videoUrl,
    String? username,
    String? description,
    int? likes,
    int? views,
    bool? isYoutubeUrl,
    DateTime? createdAt,
  }) {
    return Reel(
      id: id ?? this.id,
      videoUrl: videoUrl ?? this.videoUrl,
      username: username ?? this.username,
      description: description ?? this.description,
      likes: likes ?? this.likes,
      views: views ?? this.views,
      isYoutubeUrl: isYoutubeUrl ?? this.isYoutubeUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
