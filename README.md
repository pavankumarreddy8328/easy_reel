# easy_reel

# Easy Reel - TikTok/Instagram Style Short Video App

A full-featured short video streaming app built with Flutter, GetX state management, and Firebase Firestore.

<img width="360" height="820" alt="Screenshot_1778532945" src="https://github.com/user-attachments/assets/4bfc6964-601d-4f64-b266-4bacbd4d18d9" />
<img width="360" height="820" alt="Screenshot_1778532941" src="https://github.com/user-attachments/assets/df973dd6-5397-475f-a6ff-3bc5fcd1b329" />
<img width="360" height="820" alt="Screenshot_1778532961" src="https://github.com/user-attachments/assets/bf0e9f4d-c0bd-4ec0-b278-b4e77485ad56" />

## 📱 Screenshots & Features

### Core Features
- **🎬 Vertical Video Feed**: Smooth scrolling through short videos (like TikTok)
- **▶️ Auto Play/Pause**: Videos auto-play when in view, pause when scrolled away
- **🎥 YouTube Support**: Add YouTube URLs directly to the feed
- **💾 Smart Caching**: Videos are cached locally to avoid re-downloading
- **⚡ Preloading**: 3-4 videos preload ahead for seamless playback
- **❤️ Interactions**: Like videos, track views, comments
- **➕ Add Reels**: Easy interface to add new YouTube videos
- **📊 Real-time**: Data syncs in real-time from Firestore

### Technical Highlights
- **GetX State Management**: Proper MVC architecture with bindings
- **Firebase Integration**: Firestore for data, Storage for backups
- **Local Caching**: GetStorage for offline support
- **Clean Architecture**: Separated concerns (core, data, services, views)
- **Video Preloading**: Intelligent preloading system
- **Error Handling**: Comprehensive error management

## 🏗️ Architecture

```
easy_reel/
├── lib/
│   ├── core/                    # Core utilities and constants
│   │   ├── constants/
│   │   │   └── app_constants.dart
│   │   └── utils/
│   ├── data/                    # Data layer
│   │   ├── models/
│   │   │   └── reel_model.dart  # Data model
│   │   └── repositories/
│   │       └── reel_repository.dart  # Firestore operations
│   ├── services/                # Business logic services
│   │   └── video_cache_service.dart  # Video caching
│   ├── controllers/             # GetX controllers (state management)
│   │   └── reels_controller.dart
│   ├── bindings/                # GetX dependency injection
│   │   └── reels_binding.dart
│   ├── views/                   # UI screens
│   │   ├── reels_view.dart      # Main video feed
│   │   └── add_reel_view.dart   # Add new video screen
│   ├── routes/                  # Navigation
│   │   └── app_pages.dart
│   └── main.dart                # App entry point
├── SETUP_GUIDE.md               # Detailed setup instructions
└── README.md                    # This file
```

## 🚀 Quick Start

### Prerequisites
- Flutter 3.9.2+
- Firebase Project (free)
- Android/iOS device or emulator

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Setup Firebase
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Follow the FlutterFire CLI prompts to link your Firebase project.

### 3. Add Sample Data
- Open [Firebase Console](https://console.firebase.google.com)
- Go to Firestore Database
- Create collection: `reels`
- Add documents with:
  ```
  videoUrl: "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
  username: "demo_user"
  description: "Your description here"
  likes: 0
  views: 0
  isYoutubeUrl: true
  createdAt: (today's timestamp)
  ```

### 4. Run the App
```bash
flutter run
```

## 📖 Usage Guide

### Viewing Reels
1. Launch the app
2. Scroll vertically to browse videos
3. Videos auto-play when visible
4. Tap video to pause/resume

### Adding Videos
1. Tap the **+** button (FAB) at bottom right
2. Paste YouTube URL: `https://www.youtube.com/watch?v=...`
3. Check "This is a YouTube URL"
4. Enter username and description
5. Tap "Add Reel"

### Interacting with Videos
- **❤️ Like**: Tap heart icon to like (increments count)
- **💬 Comment**: Tap comment icon (ready for extension)
- **👁️ Views**: Auto-increments when video is viewed
- **🔄 Share**: Tap share icon (ready for extension)

## 🎥 Supported Video URLs

### YouTube URLs (Recommended)
```
https://www.youtube.com/watch?v=dQw4w9WgXcQ
https://youtu.be/dQw4w9WgXcQ
https://youtube.com/shorts/videoid
```

### Direct Video URLs
```
https://example.com/video.mp4
https://example.com/video.webm
https://cdn.example.com/video.mov
```

## 🛠️ Configuration

### App Constants (`lib/core/constants/app_constants.dart`)
```dart
const String appName = 'Easy Reel';
const int preloadCount = 3;  // Videos to preload
const int videoCacheMaxSize = 500;  // MB
const int videoCacheExpireHours = 24 * 7;  // Cache duration
```

### Firebase Options (`lib/firebase_options.dart`)
Update with your Firebase project details after running `flutterfire configure`.

## 🔐 Firestore Security Rules

Recommended rules for public read, authenticated write:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /reels/{document=**} {
      allow read;
      allow create, update, delete if request.auth != null;
    }
  }
}
```

## 🏗️ GetX Architecture Details

### State Management (Controller)
```dart
final RxList<Reel> reels = <Reel>[].obs;
final Rx<Reel?> currentReel = Rx<Reel?>(null);
final RxBool isLoading = false.obs;
final RxBool isPlaying = false.obs;
```

### Dependency Injection (Binding)
```dart
class ReelsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReelsController>(() => ReelsController());
  }
}
```

### Reactive Updates in UI
```dart
Obx(() => Text(controller.currentReel.value?.username ?? '')),
```

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `firebase_core` | Firebase initialization |
| `cloud_firestore` | Realtime database |
| `get` | State management & routing |
| `video_player` | Video playback |
| `youtube_player_flutter` | YouTube integration |
| `get_storage` | Local caching |
| `http` / `dio` | Network requests |
| `cached_network_image` | Image caching |

## 🔍 Debugging

### Firebase Emulator (Development)
```bash
firebase emulators:start
```

### View Logs
```bash
flutter logs
```

### Hot Reload During Development
```bash
flutter run -v
```

## 🐛 Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Firebase not initializing | Run `flutterfire configure` again |
| Videos won't play | Check YouTube URL validity |
| No reels displaying | Ensure Firestore has data in `reels` collection |
| Preloading fails | Check network connection and video URLs |
| Cache issues | Clear app data or call `_cacheService.clearCache()` |

## 🎨 Customization

### Change App Theme
Edit `lib/main.dart`:
```dart
colorScheme: ColorScheme.fromSeed(seedColor: Colors.yourColor),
```

### Modify Video Preload Count
Edit `lib/core/constants/app_constants.dart`:
```dart
const int preloadCount = 5;  // Changed from 3
```

### Adjust UI Layout
Edit `lib/views/reels_view.dart` - modify the `ReelCard` widget

## 🚀 Deployment

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 📝 API Reference

### ReelsController Methods
```dart
Future<void> loadReels()           // Load reels from Firestore
Future<void> playVideo(int index)  // Play video at index
Future<void> pauseVideo()          // Pause current video
Future<void> toggleLike(String id) // Like/unlike reel
Future<bool> addNewReel(Reel reel) // Add new reel
Future<void> nextReel()            // Go to next video
Future<void> previousReel()        // Go to previous video
```

### ReelRepository Methods
```dart
Future<List<Reel>> getReels()                    // Fetch all reels
Future<String> addReel(Reel reel)               // Add new reel
Future<void> updateReelLikes(String id, int likes)
Future<void> updateReelViews(String id, int views)
Future<void> deleteReel(String id)              // Delete reel
Stream<List<Reel>> streamReels()               // Real-time stream
```

## 📚 Project Structure

### Models (`data/models/`)
- `Reel`: Main data model with fromMap, toMap, copyWith methods

### Repositories (`data/repositories/`)
- `ReelRepository`: CRUD operations with Firestore

### Services (`services/`)
- `VideoCacheService`: Local caching and storage management

### Controllers (`controllers/`)
- `ReelsController`: Main state management with GetX

### Views (`views/`)
- `ReelsView`: Main video feed with PageView
- `AddReelView`: Form to add new videos

## 🎯 Future Enhancements

- [ ] User authentication and profiles
- [ ] Comments system
- [ ] Direct messaging
- [ ] Video uploads from device
- [ ] Trending page
- [ ] Search functionality
- [ ] Follow system
- [ ] Notifications
- [ ] Video filters and effects
- [ ] Live streaming support

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push and create Pull Request

## 📄 License

This project is licensed under the MIT License - see LICENSE file for details.

## 📞 Support

For issues and questions:
1. Check [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed setup
2. Review [Flutter Docs](https://docs.flutter.dev)
3. Check [Firebase Docs](https://firebase.google.com/docs)
4. Visit [GetX Docs](https://github.com/jonataslaw/getx)

## 🙏 Credits

Built with:
- Flutter Framework
- Firebase Backend
- GetX State Management
- YouTube Player Plugin

---

**Happy Coding! 🚀**

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
