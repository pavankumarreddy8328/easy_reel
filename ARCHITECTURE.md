# Easy Reel - Architecture Overview

## Project Overview

Easy Reel is a TikTok/Instagram-style short video app built with Flutter, featuring:
- Vertical scrolling video feed
- YouTube video support
- Video caching and preloading
- GetX state management
- Firebase Firestore backend
- Real-time data synchronization

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         Flutter App (UI Layer)                  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                  Views / UI Widgets                      │  │
│  │                                                          │  │
│  │  ReelsView         AddReelView        ReelCard          │  │
│  │  (Main Feed)       (Add Video)        (Video Player)    │  │
│  └────────────────────┬─────────────────────────────────────┘  │
│                       │                                         │
│  ┌────────────────────▼─────────────────────────────────────┐  │
│  │        Controllers (GetX - State Management)            │  │
│  │                                                          │  │
│  │        ReelsController                                  │  │
│  │        ├─ Observable: reels, currentReel, isLoading    │  │
│  │        ├─ Methods: loadReels, playVideo, toggleLike   │  │
│  │        └─ Video control: play, pause, preload          │  │
│  └────────────────────┬─────────────────────────────────────┘  │
│                       │                                         │
│  ┌────────────────────▼─────────────────────────────────────┐  │
│  │     Services & Business Logic (Core Application)       │  │
│  │                                                          │  │
│  │  VideoCacheService          ReelRepository             │  │
│  │  ├─ cacheReels()           ├─ getReels()              │  │
│  │  ├─ getCachedReels()       ├─ addReel()               │  │
│  │  ├─ clearCache()           ├─ updateLikes()           │  │
│  │  └─ isCacheExpired()       └─ streamReels()           │  │
│  └────────────────────┬─────────────────────────────────────┘  │
│                       │                                         │
│  ┌────────────────────▼─────────────────────────────────────┐  │
│  │            Data Layer                                   │  │
│  │                                                          │  │
│  │  Reel Model         Data Models & Type Safety          │  │
│  │  ├─ videoUrl       (Strong typing for data)           │  │
│  │  ├─ username                                           │  │
│  │  ├─ description                                        │  │
│  │  ├─ likes                                              │  │
│  │  ├─ views                                              │  │
│  │  └─ isYoutubeUrl                                       │  │
│  └────────────────────┬─────────────────────────────────────┘  │
│                       │                                         │
└───────────────────────┼─────────────────────────────────────────┘
                        │
                        │ (Firebase SDK)
                        │
        ┌───────────────┴───────────────┐
        │                               │
        ▼                               ▼
   ┌─────────────┐              ┌─────────────┐
   │ Firestore   │              │ Local Cache │
   │ (Cloud DB)  │              │ (GetStorage)│
   │             │              │             │
   │ Collections │              │ JSON Store  │
   │ - reels     │              │             │
   │             │              │ Offline     │
   │ Real-time   │              │ Support     │
   │ Streaming   │              │             │
   └─────────────┘              └─────────────┘
```

## Layer Breakdown

### 1. UI Layer (Views)

#### ReelsView
- Main screen with vertical PageView
- Displays video feed
- Handles navigation
- Shows loading states

**Key Components:**
- PageView for vertical scroll
- ReelCard widgets for each video
- Action buttons (like, comment, share)
- FAB for adding new reels

#### AddReelView
- Form to add new videos
- YouTube URL input
- Username & description
- Form validation

#### ReelCard
- Individual video player
- Video details (username, description)
- Action buttons
- Auto-play/pause logic

### 2. State Management Layer (Controllers)

#### ReelsController (GetX)
**Responsibilities:**
- Manage reels list state
- Video playback control
- Like/view updates
- Video preloading

**Observable Properties:**
```dart
RxList<Reel> reels              // All videos
Rx<Reel?> currentReel            // Currently playing
RxInt currentIndex              // Scroll position
RxBool isLoading                // Loading state
RxBool isPlaying                // Playback state
RxString errorMessage           // Error handling
RxMap videoPreloadStatus        // Preload status
```

**Key Methods:**
```dart
loadReels()                      // Fetch from Firestore
playVideo(int index)            // Play at index
pauseVideo()                    // Pause current
resumeVideo()                   // Resume playback
toggleLike(String id)           // Update likes
preloadVideos()                 // Smart preloading
addNewReel(Reel reel)          // Add to Firestore
nextReel() / previousReel()    // Navigation
```

### 3. Services Layer

#### VideoCacheService
**Purpose:** Local caching using GetStorage

**Methods:**
- `cacheReels()` - Store list locally
- `getCachedReels()` - Retrieve cached data
- `isCacheExpired()` - Check if refresh needed
- `clearCache()` - Manual cache clear
- `cacheReel()` - Cache individual video
- `getCachedReelById()` - Fetch single reel

**Storage:**
- JSON-based local storage
- 7-day default expiration
- Configured cache size limits

#### ReelRepository
**Purpose:** Firestore data operations

**Methods:**
```dart
getReels()                      // Fetch all
getReelsWithPagination()        // Paginated fetch
addReel(Reel)                   // Create
updateReelLikes()               // Update likes
updateReelViews()               // Update views
deleteReel(String)              // Delete
streamReels()                   // Real-time stream
```

### 4. Data Layer

#### Reel Model
```dart
class Reel {
  final String id;              // Firestore doc ID
  final String videoUrl;        // Video/YouTube URL
  final String username;        // Creator name
  final String description;     // Caption
  final int likes;              // Like count
  final int views;              // View count
  final bool isYoutubeUrl;      // Type identifier
  final DateTime createdAt;     // Timestamp
}
```

**Methods:**
- `fromMap()` - Convert Firestore doc to object
- `toMap()` - Convert object to Firestore doc
- `copyWith()` - Immutable updates

### 5. Infrastructure

#### Firebase Integration
- **Firestore Database**: Real-time data storage
- **Collection**: `reels` with document schema
- **Security Rules**: Public read, authenticated write
- **Real-time Streaming**: Live data updates

#### Local Storage (GetStorage)
- Persistent caching
- No SQL required
- JSON serialization
- Offline capability

#### Video Players
- **VideoPlayer**: For direct URLs
- **YoutubePlayer**: For YouTube URLs
- **Preloading**: 3-4 videos ahead
- **Auto-play/Pause**: Based on visibility

## Data Flow

### Loading Videos
```
App Start
   ↓
main.dart (Firebase Init)
   ↓
ReelsBinding (Dependency Injection)
   ↓
ReelsController.onInit()
   ↓
Check Cache (GetStorage)
   ├─ If valid → Use cached data
   └─ If expired → Fetch from Firestore
   ↓
ReelRepository.getReels()
   ↓
Firestore (Cloud)
   ↓
Parse & Cache
   ↓
Update UI (Obx)
   ↓
Display Videos
   ↓
Preload next 3 videos
```

### Adding New Reel
```
User taps "+"
   ↓
AddReelView opens
   ↓
User enters data
   ↓
Form validation
   ↓
Submit to Controller
   ↓
ReelsController.addNewReel()
   ↓
ReelRepository.addReel()
   ↓
Firestore (Cloud)
   ↓
Get document ID
   ↓
Cache locally
   ↓
Update UI
   ↓
Success notification
```

### Playing Video
```
User scrolls to video
   ↓
PageView triggers onPageChanged
   ↓
ReelsController.playVideo()
   ↓
Check video preload status
   ↓
Get VideoPlayerController
   ↓
Play video
   ↓
Mark as viewed
   ↓
Update views count in Firestore
   ↓
Preload next videos
```

## Dependency Injection (GetX Bindings)

```dart
// Global Binding
class GlobalBinding extends Bindings {
  void dependencies() {
    Get.lazyPut<ReelsController>(() => ReelsController());
  }
}

// Usage in Routes
GetPage(
  name: AppRoutes.reels,
  page: () => ReelsView(),
  binding: ReelsBinding(),
)
```

**Benefits:**
- Lazy initialization (on-demand)
- Automatic cleanup on route change
- Testable with dependency mocking
- Single responsibility

## Constants & Configuration

### AppConstants
```dart
appName = 'Easy Reel'
preloadCount = 3              // Videos to preload ahead
videoCacheMaxSize = 500       // MB
videoCacheExpireHours = 168   // 7 days
reelsCollection = 'reels'     // Firestore path
```

## Error Handling

### Try-Catch Pattern
All data operations wrap in try-catch with:
- Error logging
- User-friendly messages
- Graceful degradation
- Fallback to cache

### Observable Error State
```dart
final RxString errorMessage = ''.obs;

// Usage
Obx(() => controller.errorMessage.isNotEmpty
  ? ErrorWidget(message: controller.errorMessage.value)
  : SizedBox()
)
```

## Performance Optimizations

1. **Video Preloading**: Load 3-4 videos ahead
2. **Local Caching**: Avoid re-downloading
3. **Lazy Initialization**: Controllers load on-demand
4. **Pagination**: Potentially add for large datasets
5. **Weak Caching**: Automatic cleanup of old data
6. **Stream Optimization**: Only stream when needed

## Security Considerations

### Firestore Rules
```
- Public read access
- Authenticated write (future)
- No sensitive data in videos
- Server-side timestamps
```

### Input Validation
- URL format validation
- Username length limits
- Description text sanitization

## Extensibility Points

### Adding Features
1. **Comments**: Add `comments` subcollection
2. **User Profiles**: New `users` collection
3. **Search**: Algolia or Firestore search
4. **Notifications**: Firebase Cloud Messaging
5. **Analytics**: Firebase Analytics integration
6. **Ads**: AdMob integration

### Code Patterns
All features follow:
- GetX controller pattern
- Repository pattern for data
- Model-based type safety
- Reactive UI with Obx

## Testing Strategy

### Unit Tests
```dart
test('ReelsController loads reels', () async {
  final controller = ReelsController();
  await controller.loadReels();
  expect(controller.reels.isNotEmpty, true);
});
```

### Widget Tests
```dart
testWidgets('ReelsView displays video', (tester) async {
  await tester.pumpWidget(MyApp());
  expect(find.byType(ReelCard), findsWidgets);
});
```

### Integration Tests
- Firebase emulator
- Real Firestore testing
- End-to-end flows

## Build & Deployment

### Supported Platforms
- ✅ Android (APK, AAB)
- ✅ iOS (IPA)
- ✅ Web
- ✅ macOS (future)
- ✅ Linux (future)
- ✅ Windows (future)

### Build Commands
```bash
flutter build apk              # Android debug
flutter build appbundle        # Android release
flutter build ios              # iOS
flutter build web              # Web
```

## Related Documentation

- [SETUP_GUIDE.md](./SETUP_GUIDE.md) - Setup instructions
- [FIRESTORE_GUIDE.md](./FIRESTORE_GUIDE.md) - Database management
- [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) - Quick commands
- [README.md](./README.md) - Project overview

---

**Architecture Version**: 1.0  
**Last Updated**: 2024-01-15  
**Framework**: Flutter 3.9.2+
