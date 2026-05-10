# Easy Reel - Setup Guide

## Overview
Easy Reel is an Instagram/TikTok-style short video app built with Flutter, GetX state management, and Firebase Firestore.

## Features
✅ Video feed with vertical scroll (like TikTok)  
✅ Support for YouTube URLs and direct video links  
✅ Video preloading (3-4 videos ahead for seamless playback)  
✅ Local caching to avoid re-downloading  
✅ Auto-play/pause based on scroll position  
✅ Real-time data from Firestore  
✅ Like, view, and comment interactions  
✅ Add new reels with custom videos  

## Project Architecture

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   └── utils/
├── data/
│   ├── models/
│   │   └── reel_model.dart
│   └── repositories/
│       └── reel_repository.dart
├── services/
│   └── video_cache_service.dart
├── controllers/
│   └── reels_controller.dart
├── bindings/
│   └── reels_binding.dart
├── views/
│   ├── reels_view.dart
│   └── add_reel_view.dart
└── routes/
    └── app_pages.dart
```

## Prerequisites

1. **Flutter** (3.9.2 or higher)
2. **Firebase Project** (create at https://console.firebase.google.com)
3. **Dart** (comes with Flutter)

## Step 1: Setup Firebase Project

### 1.1 Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create a project"
3. Enter project name: `easy-reel` or similar
4. Follow the setup wizard

### 1.2 Register Your App

**For Android:**
1. Go to Project Settings → General
2. Click "Add app" → Select "Android"
3. Enter package name: `com.example.easy_reel`
4. Download `google-services.json`
5. Place it in `android/app/`

**For iOS:**
1. Click "Add app" → Select "iOS"
2. Enter Bundle ID: `com.example.easyReel`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/`

**For Web:**
1. Click "Add app" → Select "Web"
2. Copy the Firebase config

### 1.3 Setup Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click "Create database"
3. Start in **Production mode** (you can change rules later)
4. Select region: `us-central1` (or nearest to you)
5. Click "Create"

## Step 2: Configure Flutter App

### 2.1 Generate Firebase Configuration

Run FlutterFire CLI to auto-generate configuration:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# In your project root
flutterfire configure
```

This will:
- Update `lib/firebase_options.dart` automatically
- Add necessary Firebase dependencies
- Configure Android and iOS

If you prefer manual setup, see the `firebase_options.dart` template in the project.

### 2.2 Install Dependencies

```bash
flutter pub get
```

### 2.3 Build Runner (for code generation if needed)

```bash
flutter pub run build_runner build
```

## Step 3: Setup Firestore Rules

1. Go to Firestore → Rules tab
2. Replace with these rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow anyone to read reels
    match /reels/{document=**} {
      allow read;
      allow create, update, delete if request.auth != null;
    }
  }
}
```

3. Click "Publish"

## Step 4: Add Sample Data to Firestore

### Option A: Using Firebase Console (Recommended for Testing)

1. Go to **Firestore Database** → **Data** tab
2. Click **Create collection** → Name it `reels`
3. Add documents with this structure:

```
Document ID: auto-generated
Fields:
- createdAt: timestamp (today's date)
- description: string "Epic skateboard trick!"
- isYoutubeUrl: boolean (true for YouTube URLs, false for direct links)
- likes: number (0)
- username: string "demo_user"
- videoUrl: string "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
- views: number (0)
```

### Option B: Using Firebase CLI

```bash
# Install Firebase CLI if not already installed
npm install -g firebase-tools

# Login to Firebase
firebase login

# Create sample data (create a file called seed.json)
```

Create `seed.json`:
```json
{
  "reels": {
    "reel1": {
      "videoUrl": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
      "username": "demo_user",
      "description": "Amazing skateboard trick!",
      "likes": 0,
      "views": 0,
      "isYoutubeUrl": true,
      "createdAt": {"_seconds": 1704067200}
    },
    "reel2": {
      "videoUrl": "https://www.youtube.com/watch?v=9bZkp7q19f0",
      "username": "dancer123",
      "description": "Dance challenge - join us!",
      "likes": 0,
      "views": 0,
      "isYoutubeUrl": true,
      "createdAt": {"_seconds": 1704153600}
    }
  }
}
```

Then:
```bash
firebase firestore:delete reels --recursive
firebase firestore:import seed.json
```

## Step 5: Run the App

```bash
# Clean and rebuild
flutter clean
flutter pub get

# Run on your device/emulator
flutter run

# Or for specific device
flutter run -d <device-id>
```

## Step 6: Test the App

1. **View Reels**: Scroll vertically through the video feed
2. **Like Videos**: Tap the heart icon
3. **Add New Reel**: 
   - Tap the "+" button at the bottom
   - Enter YouTube URL (e.g., `https://www.youtube.com/watch?v=dQw4w9WgXcQ`)
   - Check "This is a YouTube URL"
   - Add username and description
   - Tap "Add Reel"
4. **Watch Videos**: Reels will auto-play when visible

## Example YouTube URLs to Test

- `https://www.youtube.com/watch?v=dQw4w9WgXcQ`
- `https://www.youtube.com/watch?v=9bZkp7q19f0`
- `https://youtube.com/shorts/videoid`

## Troubleshooting

### Firebase Configuration Issues
```
Error: Firebase.initializeApp() failed
→ Ensure firebase_options.dart has correct project ID
→ Verify google-services.json (Android) is in android/app/
→ Verify GoogleService-Info.plist (iOS) is in ios/Runner/
```

### Video Playback Issues
```
Error: Unable to play video
→ Check if YouTube URL is valid
→ Ensure internet connection
→ Try direct video URL instead
```

### Firestore Connection Issues
```
Error: Failed to fetch reels
→ Check Firestore rules allow read access
→ Verify internet connection
→ Check Firebase project ID matches
```

### Dependency Issues
```
Error: Package not found
→ Run: flutter pub get
→ Run: flutter clean && flutter pub get
→ Run: flutter pub upgrade
```

## Debugging Tips

1. **Enable Firebase Logging**:
```dart
// Add to main() before Firebase.initializeApp()
FirebaseOptions.currentPlatform
```

2. **Check Firestore Emulator** (for development):
```bash
firebase emulators:start
```

3. **View Logs**:
```bash
flutter logs
```

## Environment Variables (Optional)

Create `.env` file for configuration:
```
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_API_KEY=your-api-key
```

## Next Steps

1. Customize the UI and branding
2. Add user authentication
3. Implement comment system
4. Add sharing functionality
5. Deploy to App Store / Google Play

## File Descriptions

| File | Purpose |
|------|---------|
| `main.dart` | App entry point, Firebase init |
| `reels_controller.dart` | State management for reels |
| `reels_view.dart` | Main video feed UI |
| `add_reel_view.dart` | Form to add new videos |
| `reel_repository.dart` | Firestore data operations |
| `video_cache_service.dart` | Local caching logic |

## Support & Resources

- [Flutter Docs](https://docs.flutter.dev)
- [Firebase Docs](https://firebase.google.com/docs)
- [GetX Documentation](https://github.com/jonataslaw/getx)
- [YouTube Player Plugin](https://pub.dev/packages/youtube_player_flutter)

## License

This project is open source and available under the MIT License.
