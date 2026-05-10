# Easy Reel - Quick Reference Guide

## 🚀 Getting Started (5 Minutes)

### 1. Clone & Install
```bash
cd easy_reel
flutter pub get
```

### 2. Firebase Setup
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

### 3. Add Sample Data
Visit [Firebase Console](https://console.firebase.google.com) → Firestore → Create collection `reels` → Add documents

### 4. Run
```bash
flutter run
```

---

## 📱 App Features

| Feature | How to Use |
|---------|-----------|
| **Browse Videos** | Scroll vertically through feed |
| **Play/Pause** | Tap video to toggle |
| **Like Video** | Tap heart icon |
| **Add Reel** | Tap + button, paste YouTube URL |
| **View Stats** | Check likes, views, comments |

---

## 🎬 Adding Videos

### Quick Add (In App)
1. Tap "+" button
2. Paste URL: `https://www.youtube.com/watch?v=...`
3. Check "This is a YouTube URL"
4. Enter username & description
5. Tap "Add Reel"

### Bulk Add (Firebase Console)
1. Go to Firestore Database
2. Collection: `reels`
3. Add Document with fields:
   - `videoUrl` (string)
   - `username` (string)
   - `description` (string)
   - `likes` (number: 0)
   - `views` (number: 0)
   - `isYoutubeUrl` (boolean: true)
   - `createdAt` (timestamp)

### Bulk Add (CLI)
```bash
firebase firestore:import sample_data.json
```

---

## 📁 Project Structure

```
lib/
├── main.dart              ← App entry point
├── firebase_options.dart  ← Firebase config
├── core/                  ← Constants & utilities
├── data/                  ← Models & repositories
├── services/              ← Business logic
├── controllers/           ← GetX controllers
├── views/                 ← UI screens
├── bindings/              ← Dependency injection
└── routes/                ← Navigation
```

---

## 🛠️ Key Commands

```bash
# Get dependencies
flutter pub get

# Run app
flutter run

# Debug specific device
flutter run -d <device-id>

# List available devices
flutter devices

# Clean and rebuild
flutter clean && flutter pub get

# View logs
flutter logs

# Hot reload (changes code without restarting)
Press 'r' in terminal

# Hot restart (full restart)
Press 'R' in terminal

# Build APK
flutter build apk --release

# Build AppBundle
flutter build appbundle --release

# Build iOS
flutter build ios --release
```

---

## 🔐 Firebase Security Rules

For public read, authenticated write:

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

---

## 🎥 Example YouTube URLs

```
https://www.youtube.com/watch?v=dQw4w9WgXcQ
https://youtu.be/dQw4w9WgXcQ
https://youtube.com/shorts/videoid
https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=10s
```

---

## 📊 Data Model

```dart
Reel {
  id: String,                    // Document ID
  videoUrl: String,             // Video/YouTube URL
  username: String,             // Creator name
  description: String,          // Video caption
  likes: int,                   // Like count
  views: int,                   // View count
  isYoutubeUrl: bool,           // YouTube vs direct video
  createdAt: DateTime,          // Upload timestamp
}
```

---

## 🐛 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| Firebase not connecting | Run `flutterfire configure` again |
| No videos showing | Add data to `reels` collection |
| Video won't play | Check URL validity, verify `isYoutubeUrl` |
| App crashes on start | Check Firebase options, run `flutter clean` |
| GetX binding errors | Ensure binding is registered in routes |
| Video preloading slow | Check network, reduce preload count |

---

## 🏗️ GetX Architecture Basics

### State (Observable)
```dart
final RxList<Reel> reels = <Reel>[].obs;
final RxBool isLoading = false.obs;
```

### Controller
```dart
class ReelsController extends GetxController {
  Future<void> loadReels() async { ... }
}
```

### Binding (DI)
```dart
class ReelsBinding extends Bindings {
  void dependencies() {
    Get.lazyPut<ReelsController>(() => ReelsController());
  }
}
```

### View (UI)
```dart
class ReelsView extends GetView<ReelsController> {
  Obx(() => Text(controller.currentReel.value?.username ?? ''))
}
```

---

## 📚 File Descriptions

| File | Purpose |
|------|---------|
| `main.dart` | App initialization, Firebase setup |
| `reels_controller.dart` | State & business logic |
| `reels_view.dart` | Video feed UI |
| `add_reel_view.dart` | Add video form |
| `reel_repository.dart` | Firestore operations |
| `reel_model.dart` | Data structure |
| `video_cache_service.dart` | Local caching |

---

## 🌐 Network & Caching

- **Video URLs**: Direct stream from YouTube/server
- **Local Cache**: GetStorage (JSON-based)
- **Image Cache**: cached_network_image package
- **Cache Duration**: 7 days (configurable)

---

## 🎨 Customization

### Change Theme Color
Edit `lib/main.dart`:
```dart
seedColor: Colors.red,  // Change from deepPurple
```

### Modify Preload Count
Edit `lib/core/constants/app_constants.dart`:
```dart
const int preloadCount = 5;  // Was 3
```

### Adjust Cache Size
Edit `lib/core/constants/app_constants.dart`:
```dart
const int videoCacheMaxSize = 1000;  // MB
```

---

## 📖 Documentation Files

- `README.md` - Full project overview
- `SETUP_GUIDE.md` - Detailed setup instructions
- `FIRESTORE_GUIDE.md` - Database management
- `QUICK_REFERENCE.md` - This file

---

## 🚀 Next Steps

1. ✅ Setup complete
2. ✅ Add sample data
3. ✅ Run app
4. ✅ Test functionality
5. 📋 Add authentication (future)
6. 📋 Deploy to App Store

---

## 💬 Support Resources

- [Flutter Docs](https://docs.flutter.dev)
- [Firebase Docs](https://firebase.google.com/docs)
- [GetX Docs](https://github.com/jonataslaw/getx)
- [YouTube Player Docs](https://pub.dev/packages/youtube_player_flutter)

---

**Last Updated**: 2024-01-15  
**Version**: 1.0.0
