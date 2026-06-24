// Community-related data models

class CommunityUser {
  final String id;
  final String username;
  final String? profileImage;
  final String? ageGroup; // 13-17, 18-22, 23+
  final bool isVerified; // For doctors/counselors
  final String userType; // 'user', 'doctor', 'counselor'
  final DateTime joinedDate;

  CommunityUser({
    required this.id,
    required this.username,
    this.profileImage,
    this.ageGroup,
    this.isVerified = false,
    this.userType = 'user',
    required this.joinedDate,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'username': username,
    'profileImage': profileImage,
    'ageGroup': ageGroup,
    'isVerified': isVerified,
    'userType': userType,
    'joinedDate': joinedDate.toIso8601String(),
  };

  factory CommunityUser.fromMap(Map<String, dynamic> map) => CommunityUser(
    id: map['id'],
    username: map['username'],
    profileImage: map['profileImage'],
    ageGroup: map['ageGroup'],
    isVerified: map['isVerified'] ?? false,
    userType: map['userType'] ?? 'user',
    joinedDate: DateTime.parse(map['joinedDate']),
  );
}

class CommunityPost {
  final String id;
  final String userId;
  final String username;
  final String? profileImage;
  final String category; // পিরিয়ড সমস্যা, মানসিক স্বাস্থ্য, etc.
  final String content;
  final String mood; // 😭, 😔, 😊, etc.
  final DateTime createdAt;
  final Map<String, int> reactions; // emoji -> count
  final List<CommunityComment> comments;
  final int saves;
  final bool isAnonymous;
  final List<String>? flaggedReasons; // For moderation

  CommunityPost({
    required this.id,
    required this.userId,
    required this.username,
    this.profileImage,
    required this.category,
    required this.content,
    required this.mood,
    required this.createdAt,
    Map<String, int>? reactions,
    List<CommunityComment>? comments,
    this.saves = 0,
    this.isAnonymous = true,
    this.flaggedReasons,
  })  : reactions = reactions ?? {},
        comments = comments ?? [];

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'username': username,
    'profileImage': profileImage,
    'category': category,
    'content': content,
    'mood': mood,
    'createdAt': createdAt.toIso8601String(),
    'reactions': reactions,
    'comments': comments.map((c) => c.toMap()).toList(),
    'saves': saves,
    'isAnonymous': isAnonymous,
    'flaggedReasons': flaggedReasons,
  };

  factory CommunityPost.fromMap(Map<String, dynamic> map) => CommunityPost(
    id: map['id'],
    userId: map['userId'],
    username: map['username'],
    profileImage: map['profileImage'],
    category: map['category'],
    content: map['content'],
    mood: map['mood'],
    createdAt: DateTime.parse(map['createdAt']),
    reactions: Map<String, int>.from(map['reactions'] ?? {}),
    comments: (map['comments'] as List?)
        ?.map((c) => CommunityComment.fromMap(c))
        .toList() ??
        [],
    saves: map['saves'] ?? 0,
    isAnonymous: map['isAnonymous'] ?? true,
    flaggedReasons: List<String>.from(map['flaggedReasons'] ?? []),
  );
}

class CommunityComment {
  final String id;
  final String userId;
  final String username;
  final String content;
  final DateTime createdAt;
  final bool isExpertReply;
  final Map<String, int> reactions;
  final List<CommunityComment>? replies;

  CommunityComment({
    required this.id,
    required this.userId,
    required this.username,
    required this.content,
    required this.createdAt,
    this.isExpertReply = false,
    Map<String, int>? reactions,
    this.replies,
  }) : reactions = reactions ?? {};

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'username': username,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'isExpertReply': isExpertReply,
    'reactions': reactions,
    'replies': replies?.map((r) => r.toMap()).toList(),
  };

  factory CommunityComment.fromMap(Map<String, dynamic> map) => CommunityComment(
    id: map['id'],
    userId: map['userId'],
    username: map['username'],
    content: map['content'],
    createdAt: DateTime.parse(map['createdAt']),
    isExpertReply: map['isExpertReply'] ?? false,
    reactions: Map<String, int>.from(map['reactions'] ?? {}),
    replies: (map['replies'] as List?)
        ?.map((r) => CommunityComment.fromMap(r))
        .toList(),
  );
}

class ChatMessage {
  final String id;
  final String userId;
  final String username;
  final String content;
  final DateTime createdAt;
  final String roomId;
  final bool isAnonymous;

  ChatMessage({
    required this.id,
    required this.userId,
    required this.username,
    required this.content,
    required this.createdAt,
    required this.roomId,
    this.isAnonymous = true,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'username': username,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'roomId': roomId,
    'isAnonymous': isAnonymous,
  };

  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage(
    id: map['id'],
    userId: map['userId'],
    username: map['username'],
    content: map['content'],
    createdAt: DateTime.parse(map['createdAt']),
    roomId: map['roomId'],
    isAnonymous: map['isAnonymous'] ?? true,
  );
}

class ChatRoom {
  final String id;
  final String name;
  final String nameEnglish;
  final String description;
  final String emoji;
  final String category; // 'menstrual', 'mental', 'cup', etc.
  final int memberCount;
  final DateTime createdAt;

  ChatRoom({
    required this.id,
    required this.name,
    required this.nameEnglish,
    required this.description,
    required this.emoji,
    required this.category,
    this.memberCount = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'nameEnglish': nameEnglish,
    'description': description,
    'emoji': emoji,
    'category': category,
    'memberCount': memberCount,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ChatRoom.fromMap(Map<String, dynamic> map) => ChatRoom(
    id: map['id'],
    name: map['name'],
    nameEnglish: map['nameEnglish'],
    description: map['description'],
    emoji: map['emoji'],
    category: map['category'],
    memberCount: map['memberCount'] ?? 0,
    createdAt: DateTime.parse(map['createdAt']),
  );
}

class CommunityNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // 'comment', 'reaction', 'message', 'reply'
  final DateTime createdAt;
  final bool isRead;
  final String relatedPostId;

  CommunityNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    required this.relatedPostId,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'title': title,
    'message': message,
    'type': type,
    'createdAt': createdAt.toIso8601String(),
    'isRead': isRead,
    'relatedPostId': relatedPostId,
  };

  factory CommunityNotification.fromMap(Map<String, dynamic> map) => CommunityNotification(
    id: map['id'],
    userId: map['userId'],
    title: map['title'],
    message: map['message'],
    type: map['type'],
    createdAt: DateTime.parse(map['createdAt']),
    isRead: map['isRead'] ?? false,
    relatedPostId: map['relatedPostId'],
  );
}

class SafetyReport {
  final String id;
  final String reportedPostId;
  final String reportedUserId;
  final String reportedByUserId;
  final String reason; // 'harassment', 'misinformation', 'spam', 'harmful'
  final String description;
  final DateTime reportedAt;
  final String status; // 'pending', 'reviewed', 'action_taken'

  SafetyReport({
    required this.id,
    required this.reportedPostId,
    required this.reportedUserId,
    required this.reportedByUserId,
    required this.reason,
    required this.description,
    required this.reportedAt,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'reportedPostId': reportedPostId,
    'reportedUserId': reportedUserId,
    'reportedByUserId': reportedByUserId,
    'reason': reason,
    'description': description,
    'reportedAt': reportedAt.toIso8601String(),
    'status': status,
  };

  factory SafetyReport.fromMap(Map<String, dynamic> map) => SafetyReport(
    id: map['id'],
    reportedPostId: map['reportedPostId'],
    reportedUserId: map['reportedUserId'],
    reportedByUserId: map['reportedByUserId'],
    reason: map['reason'],
    description: map['description'],
    reportedAt: DateTime.parse(map['reportedAt']),
    status: map['status'] ?? 'pending',
  );
}
