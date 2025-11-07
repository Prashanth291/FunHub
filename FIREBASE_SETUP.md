# 🔥 Firebase Setup Guide for FunHub

This guide covers complete Firebase integration for authentication and database setup.

---

## 📋 Table of Contents
1. [Firebase Console Setup](#firebase-console-setup)
2. [Authentication Methods](#authentication-methods)
3. [Firestore Database Structure](#firestore-database-structure)
4. [Security Rules](#security-rules)
5. [Code Integration](#code-integration)
6. [API Methods Reference](#api-methods-reference)

---

## 🚀 Firebase Console Setup

### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Create a project"**
3. Enter project name: **FunHub**
4. Enable Google Analytics (optional)
5. Create the project

### Step 2: Add Firebase to Flutter App
1. In Firebase Console, go to **Project Settings**
2. Download `google-services.json` (Android)
3. Download `GoogleService-Info.plist` (iOS)
4. Place files in respective platform directories

Already in your project:
- ✅ `android/app/google-services.json`
- ✅ `ios/Runner/GoogleService-Info.plist` (needs to be added if missing)

### Step 3: Enable Authentication Methods

#### Email & Password Authentication
1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Enable **Email/Password** provider
3. Click **Save**

#### Google Sign-In
1. Go to **Authentication** → **Sign-in method**
2. Enable **Google** provider
3. Set a public-facing name (e.g., "FunHub")
4. Upload a support email
5. Click **Save**

For Web:
- Add your domain to authorized redirect URIs

For Android:
- Get your SHA-1 fingerprint: `keytool -list -v -keystore ~/.android/debug.keystore`
- Default password: `android`
- Add SHA-1 to Firebase Console → Project Settings

---

## 🔐 Authentication Methods

### Email/Password Authentication

```dart
// Sign Up
Future<bool> signUpWithEmail(String email, String password) async {
  try {
    final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user != null;
  } catch (e) {
    print('Sign up error: $e');
    return false;
  }
}

// Sign In
Future<bool> signInWithEmail(String email, String password) async {
  try {
    final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user != null;
  } catch (e) {
    print('Sign in error: $e');
    return false;
  }
}

// Sign Out
Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
}
```

### Google Sign-In

```dart
Future<bool> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return false;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    return userCredential.user != null;
  } catch (e) {
    print('Google sign in error: $e');
    return false;
  }
}
```

### Get Current User

```dart
User? get currentUser => FirebaseAuth.instance.currentUser;

bool get isAuthenticated => currentUser != null;

String? get userId => currentUser?.uid;

String? get userEmail => currentUser?.email;
```

---

## 📊 Firestore Database Structure

### Collection: `users`
Store user profile information

```
users/
├── userId (document ID = Firebase Auth UID)
│   ├── name: string
│   ├── email: string
│   ├── avatarUrl: string (optional)
│   ├── totalScore: number
│   ├── createdAt: timestamp
│   ├── updatedAt: timestamp
│   └── gameScores: object
│       ├── "Guess Number": number
│       ├── "Quiz Game": number
│       ├── "Memory Match": number
│       ├── "Math Challenge": number
│       ├── "Emoji Quiz": number
│       └── "Daily Challenge": number
```

### Collection: `gameScores`
Store individual game scores for leaderboard

```
gameScores/
├── scoreId (auto-generated)
│   ├── userId: string
│   ├── userName: string
│   ├── gameName: string
│   ├── score: number
│   ├── timestamp: timestamp
│   ├── difficulty: string (optional)
│   └── timeSpent: number (seconds)
```

### Example Firestore Documents

**Document: users/user123**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "avatarUrl": "https://example.com/avatar.jpg",
  "totalScore": 2450,
  "createdAt": Timestamp(2024-01-15),
  "updatedAt": Timestamp(2024-11-07),
  "gameScores": {
    "Guess Number": 350,
    "Quiz Game": 420,
    "Memory Match": 280,
    "Math Challenge": 410,
    "Emoji Quiz": 350,
    "Daily Challenge": 240
  }
}
```

**Document: gameScores/score123**
```json
{
  "userId": "user123",
  "userName": "John Doe",
  "gameName": "Quiz Game",
  "score": 420,
  "timestamp": Timestamp(2024-11-07),
  "difficulty": "hard",
  "timeSpent": 145
}
```

---

## 🔒 Security Rules

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection - users can only read/write their own data
    match /users/{userId} {
      allow read: if request.auth.uid == userId || request.auth != null;
      allow write: if request.auth.uid == userId;
      allow create: if request.auth.uid == request.resource.data.userId;
    }

    // Game scores collection - public read, only authenticated can write
    match /gameScores/{scoreId} {
      allow read: if true; // Public leaderboard
      allow create: if request.auth.uid == request.resource.data.userId;
      allow update, delete: if request.auth.uid == resource.data.userId;
    }
  }
}
```

### Firebase Authentication Rules
- Email/Password: Allow new user sign-ups ✅
- Google Sign-In: Enable in Firebase Console ✅
- Anonymous: Disable (optional)

---

## 💻 Code Integration

### Update `auth_service.dart`

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _auth.currentUser != null;

  // Sign up with email
  Future<bool> signUp(String name, String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create user document in Firestore
        await _db.collection('users').doc(credential.user!.uid).set({
          'name': name,
          'email': email,
          'avatarUrl': null,
          'totalScore': 0,
          'gameScores': {},
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        _currentUser = User(
          id: credential.user!.uid,
          name: name,
          email: email,
          totalScore: 0,
          gameScores: {},
        );
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Sign up error: $e');
      return false;
    }
  }

  // Sign in with email
  Future<bool> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _loadUserData(credential.user!.uid);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Sign in error: $e');
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Check if user exists, if not create
        final userDoc = await _db.collection('users').doc(userCredential.user!.uid).get();
        
        if (!userDoc.exists) {
          await _db.collection('users').doc(userCredential.user!.uid).set({
            'name': googleUser.displayName ?? 'User',
            'email': googleUser.email,
            'avatarUrl': googleUser.photoUrl,
            'totalScore': 0,
            'gameScores': {},
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        await _loadUserData(userCredential.user!.uid);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Google sign in error: $e');
      return false;
    }
  }

  // Load user data from Firestore
  Future<void> _loadUserData(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        _currentUser = User.fromMap(doc.data()!);
      }
    } catch (e) {
      print('Load user data error: $e');
    }
  }

  // Update profile
  Future<void> updateProfile(String name, String? avatarUrl) async {
    if (_auth.currentUser != null) {
      try {
        await _db.collection('users').doc(_auth.currentUser!.uid).update({
          'name': name,
          if (avatarUrl != null) 'avatarUrl': avatarUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        _currentUser = User(
          id: _currentUser!.id,
          name: name,
          email: _currentUser!.email,
          avatarUrl: avatarUrl ?? _currentUser!.avatarUrl,
          totalScore: _currentUser!.totalScore,
          gameScores: _currentUser!.gameScores,
        );
        notifyListeners();
      } catch (e) {
        print('Update profile error: $e');
      }
    }
  }

  // Update game score
  Future<void> updateGameScore(String gameName, int score) async {
    if (_auth.currentUser != null) {
      try {
        final userId = _auth.currentUser!.uid;
        final userRef = _db.collection('users').doc(userId);

        // Get current score
        final currentScore = _currentUser?.gameScores[gameName] ?? 0;

        // Only update if new score is higher
        if (score > currentScore) {
          await userRef.update({
            'gameScores.$gameName': score,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          // Recalculate total score
          await _updateTotalScore();

          // Add to gameScores collection for leaderboard
          await _db.collection('gameScores').add({
            'userId': userId,
            'userName': _currentUser?.name ?? 'Player',
            'gameName': gameName,
            'score': score,
            'timestamp': FieldValue.serverTimestamp(),
          });

          await _loadUserData(userId);
          notifyListeners();
        }
      } catch (e) {
        print('Update game score error: $e');
      }
    }
  }

  // Recalculate total score
  Future<void> _updateTotalScore() async {
    if (_auth.currentUser != null && _currentUser != null) {
      try {
        final totalScore = _currentUser!.gameScores.values.fold(0, (sum, score) => sum + score);
        await _db.collection('users').doc(_auth.currentUser!.uid).update({
          'totalScore': totalScore,
        });
      } catch (e) {
        print('Update total score error: $e');
      }
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  // Initialize auth state listener
  void initAuthStateListener() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _loadUserData(user.uid);
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }
}
```

---

## 🎯 API Methods Reference

### Authentication

| Method | Purpose | Returns |
|--------|---------|---------|
| `signUp(name, email, password)` | Create new account | `Future<bool>` |
| `signIn(email, password)` | Sign in with email | `Future<bool>` |
| `signInWithGoogle()` | Sign in with Google | `Future<bool>` |
| `signOut()` | Sign out user | `Future<void>` |
| `currentUser` | Get logged-in user | `User?` |
| `isAuthenticated` | Check auth status | `bool` |

### Database Operations

| Method | Purpose | Returns |
|--------|---------|---------|
| `updateProfile(name, avatarUrl)` | Update user info | `Future<void>` |
| `updateGameScore(gameName, score)` | Save game score | `Future<void>` |

### Firestore Queries (Additional)

```dart
// Get user by ID
Future<User?> getUserById(String userId) async {
  try {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.exists ? User.fromMap(doc.data()!) : null;
  } catch (e) {
    print('Get user error: $e');
    return null;
  }
}

// Get top 10 players
Future<List<User>> getTopPlayers() async {
  try {
    final snapshot = await _db
        .collection('users')
        .orderBy('totalScore', descending: true)
        .limit(10)
        .get();
    return snapshot.docs.map((doc) => User.fromMap(doc.data())).toList();
  } catch (e) {
    print('Get top players error: $e');
    return [];
  }
}

// Get leaderboard for specific game
Future<List<Map<String, dynamic>>> getGameLeaderboard(String gameName) async {
  try {
    final snapshot = await _db
        .collection('gameScores')
        .where('gameName', isEqualTo: gameName)
        .orderBy('score', descending: true)
        .limit(20)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  } catch (e) {
    print('Get game leaderboard error: $e');
    return [];
  }
}
```

---

## ✅ Testing Checklist

- [ ] Firebase project created
- [ ] google-services.json added (Android)
- [ ] GoogleService-Info.plist added (iOS)
- [ ] Email/Password authentication enabled
- [ ] Google Sign-In enabled
- [ ] Firestore database created
- [ ] Security rules applied
- [ ] `users` collection accessible
- [ ] `gameScores` collection accessible
- [ ] Test sign up with email
- [ ] Test sign in with email
- [ ] Test sign in with Google
- [ ] Test profile update
- [ ] Test score save
- [ ] Test leaderboard loading

---

## 🆘 Troubleshooting

### Issue: "PlatformException(sign_in_failed)"
- Check Google Sign-In credentials in Firebase Console
- Verify SHA-1 fingerprint for Android
- Clear app cache and rebuild

### Issue: "PERMISSION_DENIED" on Firestore
- Review Security Rules
- Ensure user is authenticated before writing
- Check user ID matches document path

### Issue: User not appearing after sign up
- Check Firestore `users` collection
- Verify Firebase project is linked
- Check network connectivity

### Issue: Scores not saving
- Verify game name matches exactly (case-sensitive)
- Check `gameScores` write permissions
- Ensure score is higher than previous

---

## 📞 Next Steps

1. ✅ Complete Firebase Console setup
2. ✅ Apply Firestore Security Rules
3. ✅ Update `auth_service.dart` with above code
4. ✅ Test authentication flow
5. ✅ Add leaderboard queries
6. ✅ Implement score tracking

**For questions, refer to:**
- [Firebase Flutter Documentation](https://firebase.flutter.dev/)
- [Firebase Authentication Guide](https://firebase.google.com/docs/auth)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/start)
