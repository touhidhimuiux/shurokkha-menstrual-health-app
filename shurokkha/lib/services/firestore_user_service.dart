import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fetch user data from Firestore
  Future<Map<String, dynamic>?> fetchUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('No authenticated user');
        return null;
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (doc.exists) {
        return doc.data();
      } else {
        print('User document does not exist');
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  /// Update user profile data in Firestore
  Future<bool> updateUserProfile({
    required String name,
    required String age,
    required String lastPeriod,
    required int cycleLength,
    String? profileImageUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('No authenticated user');
        return false;
      }

      await _firestore.collection('users').doc(user.uid).update({
        'name': name,
        'age': age,
        'lastPeriod': lastPeriod,
        'cycleLength': cycleLength,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        'updatedAt': DateTime.now(),
      });
      
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  /// Get current user email
  String? getCurrentUserEmail() {
    return _auth.currentUser?.email;
  }

  /// Get current user UID
  String? getCurrentUserUID() {
    return _auth.currentUser?.uid;
  }
}
