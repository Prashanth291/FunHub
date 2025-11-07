import 'package:flutter/material.dart';

// User Model
class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final int totalScore;
  final Map<String, int> gameScores;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.totalScore = 0,
    this.gameScores = const {},
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'totalScore': totalScore,
      'gameScores': gameScores,
    };
  }

  // Create from Firestore Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      avatarUrl: map['avatarUrl'],
      totalScore: map['totalScore'] ?? 0,
      gameScores: Map<String, int>.from(map['gameScores'] ?? {}),
    );
  }
}

// Auth Service (Mock - Replace with Firebase Auth later)
class AuthService extends ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // Mock Sign In - Replace with Firebase Auth
  Future<bool> signIn(String email, String password) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock successful login
      _currentUser = User(
        id: '1',
        name: 'John Doe',
        email: email,
        totalScore: 1250,
        gameScores: {
          'Guess Number': 200,
          'Quiz Game': 300,
          'Memory Match': 150,
          'Math Challenge': 250,
          'Emoji Quiz': 200,
          'Daily Challenge': 150,
        },
      );
      notifyListeners();
      return true;
    } catch (e) {
      print('Sign in error: $e');
      return false;
    }
  }

  // Mock Sign Up - Replace with Firebase Auth
  Future<bool> signUp(String name, String email, String password) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      _currentUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        totalScore: 0,
        gameScores: {},
      );
      notifyListeners();
      return true;
    } catch (e) {
      print('Sign up error: $e');
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    _currentUser = null;
    notifyListeners();
  }

  // Update Profile
  Future<void> updateProfile(String name, String? avatarUrl) async {
    if (_currentUser != null) {
      _currentUser = User(
        id: _currentUser!.id,
        name: name,
        email: _currentUser!.email,
        avatarUrl: avatarUrl,
        totalScore: _currentUser!.totalScore,
        gameScores: _currentUser!.gameScores,
      );
      notifyListeners();
    }
  }

  // Update Game Score
  Future<void> updateGameScore(String gameName, int score) async {
    if (_currentUser != null) {
      final updatedGameScores = Map<String, int>.from(_currentUser!.gameScores);
      final currentScore = updatedGameScores[gameName] ?? 0;

      // Only update if new score is higher
      if (score > currentScore) {
        updatedGameScores[gameName] = score;

        // Calculate new total score
        final newTotalScore = updatedGameScores.values.fold(0, (sum, score) => sum + score);

        _currentUser = User(
          id: _currentUser!.id,
          name: _currentUser!.name,
          email: _currentUser!.email,
          avatarUrl: _currentUser!.avatarUrl,
          totalScore: newTotalScore,
          gameScores: updatedGameScores,
        );
        notifyListeners();
      }
    }
  }

// TODO: Integrate with Firebase Authentication
/*
  Future<bool> signInWithFirebase(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user data from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (doc.exists) {
        _currentUser = User.fromMap(doc.data()!);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Firebase sign in error: $e');
      return false;
    }
  }

  Future<bool> signUpWithFirebase(String name, String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      final user = User(
        id: credential.user!.uid,
        name: name,
        email: email,
        totalScore: 0,
        gameScores: {},
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .set(user.toMap());

      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      print('Firebase sign up error: $e');
      return false;
    }
  }

  Future<void> signOutWithFirebase() async {
    await FirebaseAuth.instance.signOut();
    _currentUser = null;
    notifyListeners();
  }
  */
}