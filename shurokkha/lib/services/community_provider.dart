import 'package:flutter/foundation.dart';
import '../models/community_models.dart';

class CommunityProvider extends ChangeNotifier {
  // Current user community profile
  CommunityUser? _currentCommunityUser;
  
  // Posts list
  List<CommunityPost> _posts = [];
  
  // Chat rooms
  List<ChatRoom> _chatRooms = [];
  
  // Current chat messages
  List<ChatMessage> _currentChatMessages = [];
  
  // Notifications
  List<CommunityNotification> _notifications = [];
  
  // User reactions to posts
  Map<String, Map<String, dynamic>> _userReactions = {};

  // Getters
  CommunityUser? get currentCommunityUser => _currentCommunityUser;
  List<CommunityPost> get posts => _posts;
  List<ChatRoom> get chatRooms => _chatRooms;
  List<ChatMessage> get currentChatMessages => _currentChatMessages;
  List<CommunityNotification> get notifications => _notifications;
  List<CommunityNotification> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  // Categories for filtering posts
  static const List<Map<String, String>> categories = [
    {
      'bn': 'পিরিয়ড সমস্যা',
      'en': 'Period Pain',
      'emoji': '🩸',
      'id': 'period'
    },
    {
      'bn': 'মানসিক স্বাস্থ্য',
      'en': 'Mental Health',
      'emoji': '😔',
      'id': 'mental'
    },
    {
      'bn': 'মেনস্ট্রুয়াল কাপ',
      'en': 'Menstrual Cup',
      'emoji': '♻️',
      'id': 'cup'
    },
    {
      'bn': 'পরিচ্ছন্নতা',
      'en': 'Hygiene',
      'emoji': '🤍',
      'id': 'hygiene'
    },
    {
      'bn': 'খাদ্য ও পুষ্টি',
      'en': 'Nutrition',
      'emoji': '🍎',
      'id': 'nutrition'
    },
  ];

  // Mood emojis
  static const List<String> moodEmojis = ['😭', '😔', '😊', '😌', '🤔', '😨', '🥰'];

  // Reaction emojis
  static const Map<String, String> reactions = {
    'heart': '❤️',
    'hug': '🤗',
    'same': '😢',
    'helpful': '💡',
    'agree': '👍',
  };

  /// Initialize community user profile
  Future<void> initializeCommunityUser(String userId, String email) async {
    try {
      // Generate anonymous username
      String username = _generateAnonymousUsername();
      
      _currentCommunityUser = CommunityUser(
        id: userId,
        username: username,
        joinedDate: DateTime.now(),
      );
      
      // In production, save to Firestore
      notifyListeners();
    } catch (e) {
      print('Error initializing community user: $e');
    }
  }

  /// Generate anonymous username
  String _generateAnonymousUsername() {
    final adjectives = [
      'Quiet', 'Gentle', 'Bright', 'Calm', 'Happy',
      'Sweet', 'Lovely', 'Wise', 'Kind', 'Pink',
      'Silver', 'Golden', 'Rosy', 'Tiny', 'Blooming'
    ];
    final nouns = [
      'Rose', 'Moon', 'Star', 'Soul', 'Heart',
      'Dream', 'Hope', 'Friend', 'Angel', 'Bird',
      'Lily', 'Butterfly', 'Breeze', 'Peace', 'Joy'
    ];

    adjectives.shuffle();
    nouns.shuffle();
    final number = DateTime.now().microsecond % 9999;

    return '${adjectives.first}${nouns.first}_$number';
  }

  /// Create a new post
  Future<void> createPost({
    required String content,
    required String category,
    required String mood,
    bool isAnonymous = true,
  }) async {
    try {
      if (_currentCommunityUser == null) {
        throw Exception('User not initialized');
      }

      final newPost = CommunityPost(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _currentCommunityUser!.id,
        username: _currentCommunityUser!.username,
        category: category,
        content: content,
        mood: mood,
        createdAt: DateTime.now(),
        isAnonymous: isAnonymous,
      );

      _posts.insert(0, newPost);
      
      // In production, save to Firestore
      notifyListeners();
    } catch (e) {
      print('Error creating post: $e');
      rethrow;
    }
  }

  /// Load all posts (with optional filtering)
  Future<void> loadPosts({String? category}) async {
    try {
      // Initialize sample posts if empty
      if (_posts.isEmpty) {
        _posts = _generateSamplePosts();
      }

      // In production, load from Firestore
      notifyListeners();
    } catch (e) {
      print('Error loading posts: $e');
    }
  }

  /// Add reaction to post
  Future<void> addReactionToPost(
    String postId,
    String reactionKey,
  ) async {
    try {
      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex == -1) return;

      final post = _posts[postIndex];
      final reactions = Map<String, int>.from(post.reactions);
      
      reactions[reactionKey] = (reactions[reactionKey] ?? 0) + 1;
      
      _posts[postIndex] = CommunityPost(
        id: post.id,
        userId: post.userId,
        username: post.username,
        profileImage: post.profileImage,
        category: post.category,
        content: post.content,
        mood: post.mood,
        createdAt: post.createdAt,
        reactions: reactions,
        comments: post.comments,
        saves: post.saves,
        isAnonymous: post.isAnonymous,
      );

      notifyListeners();
    } catch (e) {
      print('Error adding reaction: $e');
    }
  }

  /// Add comment to post
  Future<void> addCommentToPost(
    String postId,
    String content,
  ) async {
    try {
      if (_currentCommunityUser == null) {
        throw Exception('User not initialized');
      }

      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex == -1) return;

      final post = _posts[postIndex];
      final newComment = CommunityComment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _currentCommunityUser!.id,
        username: _currentCommunityUser!.username,
        content: content,
        createdAt: DateTime.now(),
      );

      final comments = [...post.comments, newComment];
      
      _posts[postIndex] = CommunityPost(
        id: post.id,
        userId: post.userId,
        username: post.username,
        profileImage: post.profileImage,
        category: post.category,
        content: post.content,
        mood: post.mood,
        createdAt: post.createdAt,
        reactions: post.reactions,
        comments: comments,
        saves: post.saves,
        isAnonymous: post.isAnonymous,
      );

      notifyListeners();
    } catch (e) {
      print('Error adding comment: $e');
      rethrow;
    }
  }

  /// Initialize chat rooms
  Future<void> initializeChatRooms() async {
    try {
      _chatRooms = [
        ChatRoom(
          id: 'period_talk',
          name: '🩸 Period Talk',
          nameEnglish: 'Period Talk',
          description: 'পিরিয়ড সম্পর্কে কথা বলুন',
          emoji: '🩸',
          category: 'menstrual',
          createdAt: DateTime.now(),
        ),
        ChatRoom(
          id: 'mental_health',
          name: '💜 মানসিক স্বাস্থ্য',
          nameEnglish: 'Mental Health',
          description: 'আপনার মানসিক সুস্থতার জন্য সহায়তা পান',
          emoji: '💜',
          category: 'mental',
          createdAt: DateTime.now(),
        ),
        ChatRoom(
          id: 'cup_users',
          name: '♻️ Cup Users BD',
          nameEnglish: 'Cup Users Bangladesh',
          description: 'মেনস্ট্রুয়াল কাপ ব্যবহারকারীদের জন্য',
          emoji: '♻️',
          category: 'cup',
          createdAt: DateTime.now(),
        ),
        ChatRoom(
          id: 'hygiene',
          name: '🤍 স্বাস্থ্য ও পরিচ্ছন্নতা',
          nameEnglish: 'Health & Hygiene',
          description: 'স্বাস্থ্যবিধি সম্পর্কে টিপস এবং পরামর্শ',
          emoji: '🤍',
          category: 'hygiene',
          createdAt: DateTime.now(),
        ),
        ChatRoom(
          id: 'nutrition',
          name: '🍎 খাদ্য ও পুষ্টি',
          nameEnglish: 'Nutrition & Diet',
          description: 'স্বাস্থ্যকর খাওয়ার অভ্যাস গড়ুন',
          emoji: '🍎',
          category: 'nutrition',
          createdAt: DateTime.now(),
        ),
      ];

      notifyListeners();
    } catch (e) {
      print('Error initializing chat rooms: $e');
    }
  }

  /// Load chat messages for a room
  Future<void> loadChatMessages(String roomId) async {
    try {
      // In production, load from Firestore ordered by createdAt
      _currentChatMessages = _generateSampleChatMessages(roomId);
      notifyListeners();
    } catch (e) {
      print('Error loading chat messages: $e');
    }
  }

  /// Send chat message
  Future<void> sendChatMessage(
    String roomId,
    String content,
  ) async {
    try {
      if (_currentCommunityUser == null) {
        throw Exception('User not initialized');
      }

      final newMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _currentCommunityUser!.id,
        username: _currentCommunityUser!.username,
        content: content,
        createdAt: DateTime.now(),
        roomId: roomId,
      );

      _currentChatMessages.add(newMessage);
      notifyListeners();
      
      // In production, save to Firestore
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  /// Report unsafe content
  Future<void> reportContent({
    required String postId,
    required String reportedUserId,
    required String reason,
    required String description,
  }) async {
    try {
      if (_currentCommunityUser == null) {
        throw Exception('User not initialized');
      }

      final report = SafetyReport(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        reportedPostId: postId,
        reportedUserId: reportedUserId,
        reportedByUserId: _currentCommunityUser!.id,
        reason: reason,
        description: description,
        reportedAt: DateTime.now(),
      );

      // In production, save to Firestore
      // TODO: Save report to Firestore database
      print('Report created: ${report.id}');
      notifyListeners();
    } catch (e) {
      print('Error reporting content: $e');
      rethrow;
    }
  }

  /// Add notification
  void addNotification(CommunityNotification notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  /// Get all notifications
  List<CommunityNotification> getNotifications() => _notifications;

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        // Update in Firestore
        notifyListeners();
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  /// Get posts filtered by category
  List<CommunityPost> getPostsByCategory(String category) {
    return _posts.where((post) => post.category == category).toList();
  }

  /// Generate sample posts
  List<CommunityPost> _generateSamplePosts() {
    return [
      CommunityPost(
        id: '1',
        userId: 'user1',
        username: 'QuietMoon_456',
        category: 'period',
        content: 'দ্বিতীয় দিনে খুব ব্যথা হচ্ছে, কী করলে ভালো লাগবে?',
        mood: '😭',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        reactions: {'heart': 156, 'hug': 45},
        comments: [
          CommunityComment(
            id: '1_1',
            userId: 'user2',
            username: 'PinkRose_789',
            content: 'গরম পানির ব্যাগ ব্যবহার করার চেষ্টা করুন এবং হাইড্রেটেড থাকুন!',
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ],
        isAnonymous: true,
      ),
      CommunityPost(
        id: '2',
        userId: 'user3',
        username: 'CalmBreeze_234',
        category: 'mental',
        content: 'মানসিক স্বাস্থ্য টিপ: ব্যায়াম আমার উদ্বেগের জন্য গেম-চেঞ্জার হয়েছে। অত্যন্ত সুপারিশ করছি!',
        mood: '😌',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        reactions: {'helpful': 89, 'agree': 45},
        isAnonymous: true,
      ),
      CommunityPost(
        id: '3',
        userId: 'user4',
        username: 'BloomingHope_567',
        category: 'cup',
        content: 'প্রথমবার কাপ ব্যবহার করতে যাচ্ছি, খুবই ভয় পাচ্ছি। কোনো টিপস?',
        mood: '😨',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        reactions: {'hug': 234, 'same': 123},
        isAnonymous: true,
      ),
    ];
  }

  /// Generate sample chat messages
  List<ChatMessage> _generateSampleChatMessages(String roomId) {
    return [
      ChatMessage(
        id: '1',
        userId: 'user1',
        username: 'QuietMoon_456',
        content: 'হ্যালো সবাইকে! নতুন এখানে।',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        roomId: roomId,
      ),
      ChatMessage(
        id: '2',
        userId: 'user2',
        username: 'PinkRose_789',
        content: 'স্বাগতম! এখানে সবাই খুব বন্ধুত্বপূর্ণ 💜',
        createdAt: DateTime.now().subtract(const Duration(hours: 4, minutes: 30)),
        roomId: roomId,
      ),
    ];
  }

  /// Clear all data (logout)
  void clearData() {
    _currentCommunityUser = null;
    _posts.clear();
    _chatRooms.clear();
    _currentChatMessages.clear();
    _notifications.clear();
    _userReactions.clear();
    notifyListeners();
  }
}
