# Firestore Data Management Guide

This guide explains how to add, manage, and organize video data in Firebase Firestore for Easy Reel.

## Table of Contents
1. [Firestore Structure](#firestore-structure)
2. [Adding Reels](#adding-reels)
3. [Data Formats](#data-formats)
4. [Batch Operations](#batch-operations)
5. [Firestore Rules](#firestore-rules)

## Firestore Structure

### Collection: `reels`

Each document in the `reels` collection represents one video reel with this structure:

```
reels/
├── reel_001
│   ├── videoUrl: "https://www.youtube.com/watch?v=..."
│   ├── username: "user_name"
│   ├── description: "Video description"
│   ├── likes: 0
│   ├── views: 0
│   ├── isYoutubeUrl: true
│   └── createdAt: 2024-01-01 (timestamp)
├── reel_002
│   └── ...
└── reel_003
    └── ...
```

## Adding Reels

### Option 1: Firebase Console (Easiest for Testing)

1. **Go to Firebase Console**
   - Navigate to [Firebase Console](https://console.firebase.google.com)
   - Select your project

2. **Create Collection**
   - Click Firestore Database
   - Click "Create collection"
   - Name: `reels`
   - Click "Create"

3. **Add Document**
   - In `reels` collection, click "Add document"
   - Document ID: Leave as "Auto ID" (recommended)
   - Add fields:

   | Field | Type | Value |
   |-------|------|-------|
   | videoUrl | string | `https://www.youtube.com/watch?v=dQw4w9WgXcQ` |
   | username | string | `demo_user` |
   | description | string | `Epic video description` |
   | likes | number | `0` |
   | views | number | `0` |
   | isYoutubeUrl | boolean | `true` |
   | createdAt | timestamp | (select today) |

4. **Save**
   - Click Save
   - Repeat to add more videos

### Option 2: Firebase CLI (Recommended for Bulk)

1. **Install Firebase CLI**
   ```bash
   npm install -g firebase-tools
   ```

2. **Login**
   ```bash
   firebase login
   ```

3. **Create Data File (reels.json)**
   ```json
   {
     "reels": {
       "video_001": {
         "videoUrl": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
         "username": "user1",
         "description": "Amazing skateboard trick!",
         "likes": 0,
         "views": 0,
         "isYoutubeUrl": true,
         "createdAt": {
           "_seconds": 1704067200,
           "_nanoseconds": 0
         }
       },
       "video_002": {
         "videoUrl": "https://www.youtube.com/watch?v=9bZkp7q19f0",
         "username": "user2",
         "description": "Dance challenge!",
         "likes": 0,
         "views": 0,
         "isYoutubeUrl": true,
         "createdAt": {
           "_seconds": 1704153600,
           "_nanoseconds": 0
         }
       }
     }
   }
   ```

4. **Import Data**
   ```bash
   firebase firestore:import reels.json
   ```

### Option 3: Flutter App UI

1. **Launch App**
   ```bash
   flutter run
   ```

2. **Add Video**
   - Tap "+" button
   - Enter YouTube URL
   - Check "This is a YouTube URL"
   - Enter username and description
   - Tap "Add Reel"

## Data Formats

### Field Specifications

#### videoUrl (required: string)
- **Type**: String (URL)
- **Examples**:
  - `https://www.youtube.com/watch?v=dQw4w9WgXcQ`
  - `https://youtu.be/dQw4w9WgXcQ`
  - `https://youtube.com/shorts/videoid`
  - `https://example.com/video.mp4`

#### username (required: string)
- **Type**: String
- **Length**: 1-50 characters
- **Examples**: `demo_user`, `john_dancer`, `skateboard_pro`

#### description (optional: string)
- **Type**: String
- **Length**: 0-500 characters
- **Purpose**: Caption/title for the video
- **Examples**: `Epic skateboard trick!`, `Dance challenge - join us!`

#### likes (number)
- **Type**: Integer
- **Default**: 0
- **Min**: 0
- **Purpose**: Like count for the video

#### views (number)
- **Type**: Integer
- **Default**: 0
- **Min**: 0
- **Purpose**: View count for the video
- **Note**: Auto-increments when video is viewed

#### isYoutubeUrl (boolean)
- **Type**: Boolean
- **Values**: `true` or `false`
- **Purpose**: Determines how video is played
- **Examples**:
  - `true`: Uses YouTube Player
  - `false`: Uses Video Player widget

#### createdAt (timestamp)
- **Type**: Timestamp
- **Format**: ISO 8601 or Unix timestamp
- **Examples**:
  - `2024-01-15T10:30:00Z`
  - `{_seconds: 1704067200, _nanoseconds: 0}`

## Batch Operations

### Bulk Import Using Firestore Emulator

1. **Start Emulator**
   ```bash
   firebase emulators:start --only firestore
   ```

2. **Export Data**
   ```bash
   firebase firestore:export ./data-export
   ```

3. **Import Data**
   ```bash
   firebase firestore:import ./data-export
   ```

### Programmatic Operations (Dart)

```dart
// Add multiple reels at once
Future<void> addMultipleReels() async {
  final reels = [
    Reel(
      id: '',
      videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      username: 'user1',
      description: 'Great video!',
      likes: 0,
      views: 0,
      isYoutubeUrl: true,
      createdAt: DateTime.now(),
    ),
    // ... more reels
  ];

  for (var reel in reels) {
    await reelRepository.addReel(reel);
  }
}
```

## Firestore Rules

### Recommended Security Rules

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

### For Public Read/Write (Development Only)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write;
    }
  }
}
```

### For Authenticated Users Only

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /reels/{document=**} {
      allow read, write if request.auth != null;
    }
  }
}
```

## Common YouTube URLs to Test

| Description | URL |
|---|---|
| Rick Roll (Classic) | https://www.youtube.com/watch?v=dQw4w9WgXcQ |
| Music Video | https://www.youtube.com/watch?v=9bZkp7q19f0 |
| Short Format | https://youtube.com/shorts/videoid |
| With Timestamp | https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=10s |

## Troubleshooting

### No Data Appears in App
```
1. Check Firestore Rules - must allow read
2. Verify collection name is exactly "reels"
3. Check data format matches schema
4. Restart app with: flutter run --full-restart
```

### Video Won't Play
```
1. Verify isYoutubeUrl matches URL type
2. Test URL in browser first
3. Check internet connectivity
4. Try different URL format
```

### Timestamp Issues
```
// Convert Unix timestamp to ISO format
// Unix: 1704067200
// ISO: 2024-01-01T00:00:00Z

// In Firestore Console:
// Use server timestamp for current time
```

## Performance Tips

1. **Index Fields**: Create composite indexes for queries
2. **Batch Writes**: Use batch operations for multiple writes
3. **Denormalization**: Store frequently accessed data
4. **Pagination**: Use pagination for large datasets
5. **Caching**: Leverage app's built-in cache

## Backup & Restore

### Backup Firestore Data
```bash
firebase firestore:export gs://your-bucket/backup
```

### Restore Firestore Data
```bash
firebase firestore:import gs://your-bucket/backup
```

## Monitoring

### View Firestore Usage
1. Firebase Console → Firestore Database → Usage
2. Check read/write operations
3. Monitor storage usage

## Related Files

- [SETUP_GUIDE.md](../SETUP_GUIDE.md) - Firebase project setup
- [README.md](../README.md) - App overview
- `lib/data/repositories/reel_repository.dart` - Firestore queries
- `lib/data/models/reel_model.dart` - Data model

---

For more help, see [Firebase Documentation](https://firebase.google.com/docs/firestore)
