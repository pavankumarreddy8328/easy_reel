class AppConstants {
  static const String appName = 'Easy Reel';
  static const String appVersion = '1.0.0';

  // Firestore Collections
  static const String reelsCollection = 'reels';

  // Video Caching
  static const int videoCacheMaxSize = 500; // MB
  static const int videoCacheExpireHours = 24 * 7; // 1 week

  // Preloading
  static const int preloadCount = 3;

  // UI
  static const double defaultPadding = 16.0;
  static const double borderRadius = 12.0;
}
