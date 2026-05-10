#!/bin/bash

# Easy Reel - Firebase & App Setup Script
# This script automates the setup process

set -e  # Exit on any error

echo "🚀 Easy Reel - Setup Script"
echo "=========================="
echo ""

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please install Flutter first:"
    echo "   https://docs.flutter.dev/get-started/install"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -n 1)"
echo ""

# Step 1: Get dependencies
echo "📦 Installing Flutter dependencies..."
flutter pub get
echo "✅ Dependencies installed"
echo ""

# Step 2: Install FlutterFire CLI
echo "🔧 Installing FlutterFire CLI..."
if command -v flutterfire &> /dev/null; then
    echo "✅ FlutterFire CLI already installed"
else
    dart pub global activate flutterfire_cli
    echo "✅ FlutterFire CLI installed"
fi
echo ""

# Step 3: Configure Firebase
echo "🔐 Configuring Firebase..."
echo "This will launch an interactive wizard to connect your Firebase project."
echo "Make sure you have:"
echo "  1. A Firebase project created at https://console.firebase.google.com"
echo "  2. Firebase CLI installed (npm install -g firebase-tools)"
echo ""
read -p "Press enter to continue with Firebase configuration..."
echo ""

flutterfire configure

echo ""
echo "✅ Firebase configured!"
echo ""

# Step 4: Build runner (if needed)
echo "🔨 Building code generators..."
flutter pub run build_runner build --delete-conflicting-outputs 2>/dev/null || true
echo "✅ Build complete"
echo ""

# Step 5: Success message
echo "🎉 Setup Complete!"
echo ""
echo "Next steps:"
echo "1. Add sample data to Firestore:"
echo "   - Go to Firebase Console"
echo "   - Create 'reels' collection"
echo "   - Add documents with video URLs and metadata"
echo ""
echo "2. Configure Firestore security rules:"
echo "   - See SETUP_GUIDE.md for recommended rules"
echo ""
echo "3. Run the app:"
echo "   flutter run"
echo ""
echo "📖 For detailed setup, see SETUP_GUIDE.md"
echo ""
