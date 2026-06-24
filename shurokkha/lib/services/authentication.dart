import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMethod {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Validates email format (must be gmail)
  bool _isValidGmailEmail(String email) {
    final gmailRegex = RegExp(r'^[a-zA-Z0-9._%-]+@gmail\.com$');
    return gmailRegex.hasMatch(email.toLowerCase().trim());
  }

  /// Validates password requirements (minimum 6 characters)
  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  /// Check if email already exists in Firestore
  Future<bool> _emailExists(String email) async {
    try {
      final result = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase().trim())
          .get();
      return result.docs.isNotEmpty;
    } catch (e) {
      print('Error checking email existence: $e');
      return false;
    }
  }

  /// Sign Up User with comprehensive validation
  Future<String> signupUser({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Validate inputs are not empty
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        return "Please fill in all fields";
      }

      final trimmedEmail = email.toLowerCase().trim();
      final trimmedName = name.trim();
      final trimmedPassword = password;

      // Validate email format (gmail required)
      if (!_isValidGmailEmail(trimmedEmail)) {
        return "Please enter a valid Gmail address (example@gmail.com)";
      }

      // Validate password length (minimum 6 characters)
      if (!_isValidPassword(trimmedPassword)) {
        return "Password must be at least 6 characters long";
      }

      // Check if email already exists in Firestore
      if (await _emailExists(trimmedEmail)) {
        return "This email is already registered. Please login or use a different email";
      }

      // Create user in Firebase Auth
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: trimmedPassword,
      );

      // Save user data to Firestore
      await _firestore.collection("users").doc(cred.user!.uid).set({
        'name': trimmedName,
        'uid': cred.user!.uid,
        'email': trimmedEmail,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      // Send verification email
      try {
        await cred.user!.sendEmailVerification();
      } catch (e) {
        print('Email verification error (non-critical): $e');
      }

      return "success";
    } on FirebaseAuthException catch (err) {
      if (err.code == 'email-already-in-use') {
        return "This email is already registered with Firebase. Please login or use a different email";
      } else if (err.code == 'weak-password') {
        return "Password must be at least 6 characters long";
      } else if (err.code == 'invalid-email') {
        return "Please enter a valid Gmail address (example@gmail.com)";
      } else if (err.code == 'operation-not-allowed') {
        return "Email/password accounts are currently disabled";
      }
      return "Signup failed: ${err.message}";
    } catch (err) {
      print('Signup error: $err');
      return "An unexpected error occurred. Please try again";
    }
  }

  /// Login user with comprehensive validation
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // Validate inputs are not empty
      if (email.isEmpty || password.isEmpty) {
        return "Please enter both email and password";
      }

      final trimmedEmail = email.toLowerCase().trim();

      // Validate email format
      if (!_isValidGmailEmail(trimmedEmail)) {
        return "Please enter a valid Gmail address (example@gmail.com)";
      }

      // Attempt login
      await _auth.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );

      return "success";
    } on FirebaseAuthException catch (err) {
      if (err.code == 'user-not-found') {
        return "This email is not registered. Please sign up first";
      } else if (err.code == 'wrong-password') {
        return "Incorrect password. Please try again";
      } else if (err.code == 'invalid-email') {
        return "Please enter a valid Gmail address (example@gmail.com)";
      } else if (err.code == 'user-disabled') {
        return "This account has been disabled. Please contact support";
      } else if (err.code == 'invalid-credential') {
        return "Invalid email or password. Please try again";
      }
      return "Login failed: ${err.message}";
    } catch (err) {
      print('Login error: $err');
      return "An unexpected error occurred. Please try again";
    }
  }

  /// Send password reset email
  Future<String> sendPasswordResetEmail(String email) async {
    try {
      final trimmedEmail = email.toLowerCase().trim();

      if (trimmedEmail.isEmpty) {
        return "Please enter your email";
      }

      if (!_isValidGmailEmail(trimmedEmail)) {
        return "Please enter a valid Gmail address (example@gmail.com)";
      }

      // Check if email exists in Firestore
      if (!await _emailExists(trimmedEmail)) {
        return "This email is not registered. Please sign up first";
      }

      await _auth.sendPasswordResetEmail(email: trimmedEmail);
      return "success";
    } on FirebaseAuthException catch (err) {
      if (err.code == 'user-not-found') {
        return "This email is not registered. Please sign up first";
      } else if (err.code == 'invalid-email') {
        return "Please enter a valid Gmail address";
      }
      return "Failed to send reset email: ${err.message}";
    } catch (err) {
      print('Password reset error: $err');
      return "An unexpected error occurred. Please try again";
    }
  }

  /// Update user password
  Future<String> updatePassword(String newPassword) async {
    try {
      if (newPassword.isEmpty) {
        return "Password cannot be empty";
      }

      if (!_isValidPassword(newPassword)) {
        return "Password must be at least 6 characters long";
      }

      final user = _auth.currentUser;
      if (user == null) {
        return "No user is currently logged in";
      }

      await user.updatePassword(newPassword);

      // Update updatedAt timestamp in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'updatedAt': Timestamp.now(),
      });

      return "success";
    } on FirebaseAuthException catch (err) {
      if (err.code == 'weak-password') {
        return "Password must be at least 6 characters long";
      } else if (err.code == 'requires-recent-login') {
        return "Please log out and log back in before changing your password";
      }
      return "Failed to update password: ${err.message}";
    } catch (err) {
      print('Password update error: $err');
      return "An unexpected error occurred. Please try again";
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (err) {
      print('Sign out error: $err');
    }
  }
}