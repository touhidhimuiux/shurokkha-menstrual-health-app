import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; 

class AuthProvider extends ChangeNotifier {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _isOnboardingCompletedKey = 'is_onboarding_completed';
  static const String _phoneKey = 'user_phone';
  static const String _userNameKey = 'user_name';
  static const String _emailKey = 'user_email';
  static const String _ageKey = 'user_age';
  static const String _lastPeriodKey = 'last_period';
  static const String _cycleKey = 'cycle_length';
  static const String _authMethodKey = 'auth_method';
  static const String _profileImageUrlKey = 'user_profile_image_url';

  bool _isLoggedIn = false;
  bool _isOnboardingCompleted = false;
  String? _phoneNumber;
  String? _userEmail;
  String? _userName;
  String? _userAge;
  String? _lastPeriodDate;
  int? _cycleLength;
  String _authMethod = 'phone';
  String? _profileImageUrl;

  // ================= GETTERS =================
  bool get isLoggedIn => _isLoggedIn;
  bool get isOnboardingCompleted => _isOnboardingCompleted;
  String? get phoneNumber => _phoneNumber;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get userAge => _userAge;
  String? get lastPeriodDate => _lastPeriodDate;
  int? get cycleLength => _cycleLength;
  String get authMethod => _authMethod;
  String? get profileImageUrl => _profileImageUrl;
  
  // SECURE UID GETTER FOR FIRESTORE CHAT/DATA
  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadAuthData();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _isLoggedIn = true;
        if (user.email != null) _userEmail = user.email;
        if (user.displayName != null) _userName = user.displayName;
        
        // 🚀 FIX: Fetch profile image directly from Firebase Auth if local is empty
        if (user.photoURL != null && (_profileImageUrl == null || _profileImageUrl!.isEmpty)) {
          _profileImageUrl = user.photoURL;
        }
        
        // 🚀 NEW ADDITION: Ensure the user document exists in Firestore to prevent crashes
        _syncUserToFirestore(user);
        
        notifyListeners();
      }
    });
  }

  // ================= 🚀 NEW ADDITION: SYNC MISSING USER DOC =================
  Future<void> _syncUserToFirestore(User currentUser) async {
    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
      final snapshot = await userRef.get();

      // If the document doesn't exist (caused the error), create it automatically!
      if (!snapshot.exists) {
        await userRef.set({
          'uid': currentUser.uid,
          'name': currentUser.displayName ?? _userName ?? 'New User',
          'email': currentUser.email ?? _userEmail ?? '',
          'profileImageUrl': currentUser.photoURL ?? _profileImageUrl ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'age': _userAge ?? '',
          'lastPeriod': _lastPeriodDate ?? '',
          'cycleLength': _cycleLength ?? 28,
        });
        debugPrint("✅ Created missing user document in Firestore!");
      }
    } catch (e) {
      debugPrint("Error syncing user to Firestore: $e");
    }
  }

  // ================= NEW: UPLOAD PROFILE IMAGE TO FIREBASE =================
  Future<void> uploadProfileImage(File imageFile) async {
    try {
      final userId = uid;
      if (userId == null) throw Exception('No authenticated user found.');

      // 1. Upload Image to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$userId.jpg'); // Saves as the user's UID

      await storageRef.putFile(imageFile);

      // 2. Get the Secure Download URL
      final downloadUrl = await storageRef.getDownloadURL();

      // 3. Save URL to Firestore Database
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'profileImageUrl': downloadUrl,
      });

      // 🚀 FIX: Update Firebase Auth Profile so it works perfectly in Chat
      await FirebaseAuth.instance.currentUser?.updatePhotoURL(downloadUrl);

      // 4. Update Local State & SharedPreferences so UI updates instantly
      _profileImageUrl = downloadUrl;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileImageUrlKey, downloadUrl);

      notifyListeners();
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      throw Exception('Failed to upload image. Please try again.');
    }
  }

  Future<void> _clearLocalState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      _isLoggedIn = false;
      _isOnboardingCompleted = false;
      _phoneNumber = null;
      _userEmail = null;
      _userName = null;
      _userAge = null;
      _lastPeriodDate = null;
      _cycleLength = null;
      _authMethod = 'phone';
      _profileImageUrl = null;

      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing local state: $e');
    }
  }

  Future<void> _loadAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      _isOnboardingCompleted = prefs.getBool(_isOnboardingCompletedKey) ?? false;
      _phoneNumber = prefs.getString(_phoneKey);
      _userEmail = prefs.getString(_emailKey);
      _userName = prefs.getString(_userNameKey);
      _userAge = prefs.getString(_ageKey);
      _lastPeriodDate = prefs.getString(_lastPeriodKey);
      _cycleLength = prefs.getInt(_cycleKey);
      _authMethod = prefs.getString(_authMethodKey) ?? 'phone';
      _profileImageUrl = prefs.getString(_profileImageUrlKey);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading auth data: $e');
    }
  }

  // ================= NEW: FIREBASE SIGNUP =================
  Future<void> signupWithEmail(String name, String email, String password) async {
    try {
      UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      User? user = cred.user;
      if (user != null) {
        await user.updateDisplayName(name.trim());
        
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name.trim(),
          'email': email.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'age': '',
          'lastPeriod': '',
          'cycleLength': 28,
          'profileImageUrl': '',
        });

        _isLoggedIn = true;
        _userEmail = email.trim();
        _userName = name.trim();
        _profileImageUrl = '';
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_isLoggedInKey, true);
        await prefs.setString(_userNameKey, _userName!);
        await prefs.setString(_emailKey, _userEmail!);
        await prefs.setString(_profileImageUrlKey, '');
        
        notifyListeners();
      }
    } on FirebaseAuthException catch (e) {
      // 🚀 FIX: Handle Firebase Signup Errors gracefully
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('An account already exists for that email.');
      } else {
        throw Exception(e.message ?? 'Signup failed.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred.');
    }
  }

  // ================= NEW: FIREBASE LOGIN =================
  Future<void> loginWithEmail(String email, String password) async {
    try {
      UserCredential cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = cred.user;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        
        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          _userName = data['name'] ?? user.displayName;
          _userAge = data['age']?.toString();
          _lastPeriodDate = data['lastPeriod'];
          _cycleLength = data['cycleLength'];
          
          // 🚀 FIX: Fetch image from Firestore first, fallback to Auth if empty
          _profileImageUrl = data['profileImageUrl'] ?? user.photoURL;
          
          final prefs = await SharedPreferences.getInstance();
          if (_userName != null) await prefs.setString(_userNameKey, _userName!);
          if (_userAge != null) await prefs.setString(_ageKey, _userAge!);
          if (_lastPeriodDate != null) await prefs.setString(_lastPeriodKey, _lastPeriodDate!);
          if (_cycleLength != null) await prefs.setInt(_cycleKey, _cycleLength!);
          if (_profileImageUrl != null) await prefs.setString(_profileImageUrlKey, _profileImageUrl!);
        }

        _isLoggedIn = true;
        _userEmail = email.trim();
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_isLoggedInKey, true);
        await prefs.setString(_emailKey, _userEmail!);
        
        notifyListeners();
      }
    } on FirebaseAuthException catch (e) {
      // 🚀 FIX: Handle Firebase Login Errors gracefully
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('Invalid email or password. Please try again.');
      } else {
        throw Exception(e.message ?? 'Login failed.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred.');
    }
  }

  // ================= PRESERVED EXISTING METHODS =================
  Future<void> setPhoneNumber(String phone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_phoneKey, phone);
      await prefs.setString(_authMethodKey, 'phone');
      _phoneNumber = phone;
      _authMethod = 'phone';
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting phone number: $e');
    }
  }

  Future<void> setUserEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_emailKey, email);
      _userEmail = email;
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting email: $e');
    }
  }

  Future<void> updateFromMap(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _userName = data['name'] ?? _userName;
      _userAge = data['age']?.toString() ?? _userAge;
      _profileImageUrl = data['profileImageUrl'] ?? _profileImageUrl;
      _lastPeriodDate = data['lastPeriod'] ?? _lastPeriodDate;
      _cycleLength = data['cycleLength'] ?? _cycleLength;

      if (_userName != null) await prefs.setString(_userNameKey, _userName!);
      if (_userAge != null) await prefs.setString(_ageKey, _userAge!);
      if (_profileImageUrl != null) await prefs.setString(_profileImageUrlKey, _profileImageUrl!);
      if (_lastPeriodDate != null) await prefs.setString(_lastPeriodKey, _lastPeriodDate!);
      if (_cycleLength != null) await prefs.setInt(_cycleKey, _cycleLength!);

      notifyListeners();
    } catch (e) {
      debugPrint('Error syncing from map: $e');
    }
  }

  Future<void> setProfileData({
    String? name, String? email, String? age, String? lastPeriod, int? cycleLength, String? profileImageUrl, 
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (name != null) { _userName = name; await prefs.setString(_userNameKey, name); }
      if (email != null) { _userEmail = email; await prefs.setString(_emailKey, email); }
      if (age != null) { _userAge = age; await prefs.setString(_ageKey, age); }
      if (lastPeriod != null) { _lastPeriodDate = lastPeriod; await prefs.setString(_lastPeriodKey, lastPeriod); }
      if (cycleLength != null) { _cycleLength = cycleLength; await prefs.setInt(_cycleKey, cycleLength); }
      if (profileImageUrl != null) { _profileImageUrl = profileImageUrl; await prefs.setString(_profileImageUrlKey, profileImageUrl); }
      notifyListeners();
    } catch (e) {}
  }

  Future<void> setUserProfile({
    required String name, required String age, required String lastPeriod, required int cycleLength, String? profileImageUrl,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userNameKey, name);
      await prefs.setString(_ageKey, age);
      await prefs.setString(_lastPeriodKey, lastPeriod);
      await prefs.setInt(_cycleKey, cycleLength);

      if (profileImageUrl != null) {
        await prefs.setString(_profileImageUrlKey, profileImageUrl);
        _profileImageUrl = profileImageUrl;
      }

      _userName = name;
      _userAge = age;
      _lastPeriodDate = lastPeriod;
      _cycleLength = cycleLength;
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting profile: $e');
    }
  }

  Future<void> login() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      _isLoggedIn = true;
      notifyListeners();
    } catch (e) {}
  }

  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isOnboardingCompletedKey, true);
      _isOnboardingCompleted = true;
      notifyListeners();
    } catch (e) {}
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      await _clearLocalState();
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  bool isFirstTimeUser() {
    return !_isLoggedIn && _phoneNumber == null;
  }
}