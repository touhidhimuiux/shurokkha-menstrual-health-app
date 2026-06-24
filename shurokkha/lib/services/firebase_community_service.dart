import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

class CommunityMessage {
  final String id;
  final String userId;
  final String username;
  final String message;
  final DateTime timestamp;
  final bool isAnonymous;

  CommunityMessage({
    required this.id,
    required this.userId,
    required this.username,
    required this.message,
    required this.timestamp,
    this.isAnonymous = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isAnonymous': isAnonymous,
    };
  }

  factory CommunityMessage.fromMap(Map<String, dynamic> map) {
    return CommunityMessage(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      username: map['username'] ?? 'Anonymous',
      message: map['message'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      isAnonymous: map['isAnonymous'] ?? true,
    );
  }
}

class FirebaseCommunityChatService {
  static final FirebaseCommunityChatService _instance =
      FirebaseCommunityChatService._internal();

  factory FirebaseCommunityChatService() {
    return _instance;
  }

  FirebaseCommunityChatService._internal();

  late DatabaseReference _chatRef;
  static const String _dbPath = 'community_chat';
  bool _isInitialized = false;

  // Initialize Firebase
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Firebase.initializeApp();
      _chatRef = FirebaseDatabase.instance.ref(_dbPath);
      _isInitialized = true;
      debugLog('Firebase initialized successfully');
    } catch (e) {
      debugLog('Firebase initialization error: $e');
      rethrow;
    }
  }

  void debugLog(String message) {
    print('[FirebaseCommunityChatService] $message');
  }

  // Send a message to community chat
  Future<String> sendMessage({
    required String userId,
    required String username,
    required String message,
    bool isAnonymous = true,
  }) async {
    if (!_isInitialized) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }

    try {
      if (message.trim().isEmpty) {
        throw Exception('Message cannot be empty');
      }

      final messageId = DateTime.now().millisecondsSinceEpoch.toString();

      final communityMessage = CommunityMessage(
        id: messageId,
        userId: userId,
        username: username,
        message: message.trim(),
        timestamp: DateTime.now(),
        isAnonymous: isAnonymous,
      );

      await _chatRef.child(messageId).set(communityMessage.toMap());
      debugLog('Message sent successfully: $messageId');
      return messageId;
    } catch (e) {
      debugLog('Error sending message: $e');
      rethrow;
    }
  }

  // Get all messages (real-time stream)
  Stream<List<CommunityMessage>> getMessagesStream() {
    if (!_isInitialized) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }

    return _chatRef.orderByChild('timestamp').onValue.map((event) {
      final messages = <CommunityMessage>[];

      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          try {
            final message = CommunityMessage.fromMap(
              Map<String, dynamic>.from(value),
            );
            messages.add(message);
          } catch (e) {
            debugLog('Error parsing message: $e');
          }
        });
      }

      // Sort by timestamp (newest first)
      messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return messages;
    }).handleError((error) {
      debugLog('Stream error: $error');
      throw error;
    });
  }

  // Get recent messages (last N messages)
  Future<List<CommunityMessage>> getRecentMessages({int limit = 50}) async {
    if (!_isInitialized) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }

    try {
      final query = _chatRef.limitToLast(limit);
      final snapshot = await query.get();

      final messages = <CommunityMessage>[];
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          try {
            final message = CommunityMessage.fromMap(
              Map<String, dynamic>.from(value),
            );
            messages.add(message);
          } catch (e) {
            debugLog('Error parsing message: $e');
          }
        });
      }

      // Sort by timestamp (newest first)
      messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return messages;
    } catch (e) {
      debugLog('Error fetching recent messages: $e');
      rethrow;
    }
  }

  // Delete a message (admin/own message)
  Future<void> deleteMessage(String messageId) async {
    if (!_isInitialized) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }

    try {
      await _chatRef.child(messageId).remove();
      debugLog('Message deleted: $messageId');
    } catch (e) {
      debugLog('Error deleting message: $e');
      rethrow;
    }
  }

  // Get message count
  Future<int> getMessageCount() async {
    if (!_isInitialized) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }

    try {
      final snapshot = await _chatRef.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return data.length;
      }
      return 0;
    } catch (e) {
      debugLog('Error getting message count: $e');
      return 0;
    }
  }

  // Clear all messages (admin only)
  Future<void> clearAllMessages() async {
    if (!_isInitialized) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }

    try {
      await _chatRef.remove();
      debugLog('All messages cleared');
    } catch (e) {
      debugLog('Error clearing messages: $e');
      rethrow;
    }
  }
}
