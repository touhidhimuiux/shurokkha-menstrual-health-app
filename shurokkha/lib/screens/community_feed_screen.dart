import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'home_screen.dart';
import 'period_tracker_screen.dart';
import 'chat_screen.dart';
import 'shop_screen.dart';

class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  final TextEditingController _postController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;
  File? _selectedImage;
  bool _isPosting = false; 

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 40);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _createPost() async {
    if (_postController.text.trim().isEmpty && _selectedImage == null) return;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please log in to post.")));
      return; 
    }

    setState(() => _isPosting = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    String? base64Image;

    try {
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        base64Image = base64Encode(bytes);
      }

      await _firestore.collection('posts').add({
        'authorName': auth.userName ?? currentUser?.displayName ?? 'Anonymous',
        'authorId': currentUser!.uid,
        'authorAvatar': auth.profileImageUrl ?? currentUser?.photoURL ?? '',
        'content': _postController.text.trim(),
        'image': base64Image, 
        'timestamp': FieldValue.serverTimestamp(),
        'reactions': {}, 
      });

      setState(() {
        _postController.clear();
        _selectedImage = null;
        _isPosting = false;
      });
      FocusScope.of(context).unfocus(); 

    } catch (e) {
      setState(() => _isPosting = false);
      debugPrint("Post Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to upload post. The image might be too large.")));
    }
  }

  Future<void> _deletePost(String postId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Post"),
        content: const Text("Are you sure you want to delete this post? This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _firestore.collection('posts').doc(postId).delete();
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _filterAuthenticReactions(Map<String, dynamic>? rawReactions) {
    if (rawReactions == null) return {};
    
    Map<String, dynamic> authentic = {};
    final validEmojis = ['👍', '❤️', '😂', '😮', '😢', '😡'];

    rawReactions.forEach((key, value) {
      if (key.isNotEmpty && key != 'null' && key.length > 10) {
        if (validEmojis.contains(value.toString())) {
          authentic[key] = value;
        }
      }
    });
    return authentic;
  }

  Future<void> _handleReaction(String id, Map<String, dynamic> reactions, String selectedEmoji, {bool isPost = true, String? parentPostId}) async {
    final userId = currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please log in to react.")));
      return; 
    }

    DocumentReference ref = isPost 
        ? _firestore.collection('posts').doc(id)
        : _firestore.collection('posts').doc(parentPostId!).collection('comments').doc(id);

    if (reactions[userId] == selectedEmoji) {
      await ref.update({'reactions.$userId': FieldValue.delete()});
    } else {
      await ref.update({'reactions.$userId': selectedEmoji});
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if (currentUser == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFFC9CCD1), 
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryPurple),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen())),
        ),
        title: Text('Community', style: TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildPostCreator(auth),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('posts').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) => _buildPostCard(snapshot.data!.docs[index]),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: 4, onTap: _navigate),
    );
  }

  Widget _buildPostCreator(AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      margin: const EdgeInsets.only(bottom: 8.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end, 
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: _buildAvatar(auth.profileImageUrl ?? currentUser?.photoURL, auth.userName),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _postController,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  minLines: 1,
                  maxLines: null, 
                  decoration: InputDecoration(
                    hintText: "What's on your mind?",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20), 
                      borderSide: BorderSide.none
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.photo_library, color: Colors.green),
                      onPressed: _pickImage,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: InkWell(
  onTap: _createPost,
  child: CircleAvatar(
    backgroundColor: AppColors.primaryPurple,
    radius: 20,
    child: const Icon(
      Icons.send,
      color: Colors.white,
      size: 20,
    ),
  ),
),
              ),
            ],
          ),
          if (_selectedImage != null)
            Padding(
              padding: const EdgeInsets.only(top: 12.0, left: 52.0),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_selectedImage!, height: 120, width: 120, fit: BoxFit.cover),
                  ),
                  Positioned(
                    right: -10,
                    top: -10,
                    child: IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.redAccent),
                      onPressed: () => setState(() => _selectedImage = null),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPostCard(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Map<String, dynamic> authenticReactions = _filterAuthenticReactions(data['reactions']);

    String? myReaction = authenticReactions[currentUser?.uid];
    bool isMine = data['authorId'] == currentUser?.uid;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🚀 REAL-TIME DYNAMIC POST HEADER 🚀
          StreamBuilder<DocumentSnapshot>(
            stream: _firestore.collection('users').doc(data['authorId']).snapshots(),
            builder: (context, userSnapshot) {
              // Fallback to static post data while loading
              String displayName = data['authorName'] ?? 'User';
              String displayAvatar = data['authorAvatar'] ?? '';

              // If database has updated user info, use it!
              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                displayName = userData['name'] ?? displayName;
                displayAvatar = userData['profileImageUrl'] ?? displayAvatar;
              }

              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    _buildAvatar(displayAvatar, displayName),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(_formatTime(data['timestamp']), style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        ],
                      ),
                    ),
                    if (isMine)
                      IconButton(
                        icon: const Icon(Icons.more_horiz, color: Colors.grey),
                        onPressed: () => _deletePost(doc.id),
                      ),
                  ],
                ),
              );
            }
          ),
          
          if (data['content'] != null && data['content'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: Text(data['content'], style: const TextStyle(fontSize: 15)),
            ),
            
          if (data['image'] != null && data['image'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Image.memory(base64Decode(data['image']), width: double.infinity, fit: BoxFit.cover),
            ),
            
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Row(
              children: [
                if (authenticReactions.isNotEmpty) _buildReactionSummaryRow(authenticReactions),
                const Spacer(),
                _buildCommentCount(doc.id),
              ],
            ),
          ),
            
          const Divider(height: 1, thickness: 1),
          
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onLongPress: () => _showEmojiPicker(doc.id, authenticReactions, true),
                  onTap: () {
                    if (currentUser == null) return;
                    if (myReaction == null) {
                      _showEmojiPicker(doc.id, authenticReactions, true);
                    } else {
                      _handleReaction(doc.id, authenticReactions, myReaction);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (myReaction == null)
                          Icon(Icons.add_reaction_outlined, size: 20, color: Colors.grey.shade600)
                        else
                          Text(myReaction, style: const TextStyle(fontSize: 18)),
                          
                        const SizedBox(width: 6),
                        Text(myReaction != null ? "Reacted" : "React", style: TextStyle(color: myReaction == null ? Colors.grey.shade600 : Colors.blue, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => _showCommentsModal(doc.id),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text("Comment", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReactionSummaryRow(Map<String, dynamic> reactions) {
    if (reactions.isEmpty) return const SizedBox();

    List<String> uniqueEmojis = reactions.values.map((e) => e.toString()).toSet().take(3).toList();
    int count = reactions.length;
    String firstReactorId = reactions.keys.first;

    return InkWell(
      onTap: () => _showReactionListModal(reactions),
      child: Row(
        children: [
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(firstReactorId).get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || !snapshot.data!.exists) return const SizedBox();
              var userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
              String avatar = userData['profileImageUrl'] ?? '';
              return Container(
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                child: _buildAvatar(avatar, userData['name'] ?? 'U', radius: 10.0),
              );
            },
          ),
          Row(
            children: uniqueEmojis.map((emoji) => Container(
              margin: const EdgeInsets.only(right: 2),
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: Colors.white, width: 1)),
              child: Text(emoji, style: const TextStyle(fontSize: 14)),
            )).toList(),
          ),
          const SizedBox(width: 4),
          Text('$count', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildCommentCount(String postId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('posts').doc(postId).collection('comments').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        int count = snapshot.data!.docs.length;
        if (count == 0) return const SizedBox(); 
        return InkWell(
          onTap: () => _showCommentsModal(postId),
          child: Text('$count comments', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        );
      },
    );
  }

  void _showReactionListModal(Map<String, dynamic> reactions) {
    List<MapEntry<String, dynamic>> reactionEntries = reactions.entries.toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Text("Reactions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text("${reactions.length}", style: const TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: reactionEntries.length,
                itemBuilder: (context, index) {
                  String uid = reactionEntries[index].key;
                  String emoji = reactionEntries[index].value;

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const ListTile(title: Text("Loading..."));
                      var userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                      String name = userData['name'] ?? 'Unknown User';
                      String avatar = userData['profileImageUrl'] ?? '';

                      return ListTile(
                        leading: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            _buildAvatar(avatar, name),
                            Container(
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                              child: Text(emoji, style: const TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEmojiPicker(String id, Map<String, dynamic> reactions, bool isPost, {String? parentPostId}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['👍', '❤️', '😂', '😮', '😢', '😡'].map((emoji) => InkWell(
            onTap: () {
              _handleReaction(id, reactions, emoji, isPost: isPost, parentPostId: parentPostId);
              Navigator.pop(context);
            },
            child: Text(emoji, style: const TextStyle(fontSize: 32)),
          )).toList(),
        ),
      ),
    );
  }

  void _showCommentsModal(String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _CommentSection(
        postId: postId, 
        buildAvatar: _buildAvatar, 
        showEmoji: _showEmojiPicker, 
        formatTime: _formatTime, 
        showReactionList: _showReactionListModal,
        filterAuthenticReactions: _filterAuthenticReactions, 
        handleReaction: _handleReaction,
      ),
    );
  }

  Widget _buildAvatar(String? url, String? name, {double radius = 20}) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryPurple.withOpacity(0.1),
      backgroundImage: (url != null && url.isNotEmpty) ? (url.startsWith('http') ? NetworkImage(url) : MemoryImage(base64Decode(url)) as ImageProvider) : null,
      child: (url == null || url.isEmpty) ? Text(name?[0].toUpperCase() ?? 'U', style: TextStyle(color: AppColors.primaryPurple, fontSize: radius * 0.8)) : null,
    );
  }

  String _formatTime(Timestamp? t) => t == null ? "Just now" : DateFormat('MMM d, h:mm a').format(t.toDate());

  void _navigate(int i) {
    if (i == 4) return;
    Widget screen = const HomeScreen();
    if (i == 1) screen = const PeriodTrackerScreen();
    if (i == 2) screen = const ChatScreen();
    if (i == 3) screen = const ShopScreen();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => screen));
  }
}

// ==================== COMMENT SECTION WIDGET ====================

class _CommentSection extends StatefulWidget {
  final String postId;
  final Function buildAvatar;
  final Function showEmoji;
  final Function formatTime;
  final Function showReactionList;
  final Function filterAuthenticReactions;
  final Function handleReaction;

  const _CommentSection({
    required this.postId, 
    required this.buildAvatar, 
    required this.showEmoji, 
    required this.formatTime, 
    required this.showReactionList,
    required this.filterAuthenticReactions,
    required this.handleReaction,
  });

  @override
  State<_CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<_CommentSection> {
  final TextEditingController _commentCtrl = TextEditingController();
  final FocusNode _commentFocus = FocusNode();
  final Set<String> _hiddenComments = {}; 
  String? _replyingToName;

  @override
  void dispose() {
    _commentCtrl.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  void _startReply(String name) {
    setState(() => _replyingToName = name);
    _commentFocus.requestFocus();
  }

  void _showCommentOptions(String commentId, bool isMine) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isMine)
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("Delete Comment", style: TextStyle(color: Colors.red)),
              onTap: () async {
                await FirebaseFirestore.instance.collection('posts').doc(widget.postId).collection('comments').doc(commentId).delete();
                Navigator.pop(context);
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.visibility_off, color: Colors.grey),
              title: const Text("Hide Comment"),
              onTap: () {
                setState(() => _hiddenComments.add(commentId));
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16), 
            child: Text("Comments", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('posts').doc(widget.postId).collection('comments').orderBy('timestamp').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, i) {
                    var doc = snapshot.data!.docs[i];
                    if (_hiddenComments.contains(doc.id)) return const SizedBox(); 

                    var data = doc.data() as Map<String, dynamic>;
                    var authenticReactions = widget.filterAuthenticReactions(data['reactions']);
                    
                    return _buildFacebookStyleComment(doc.id, data, authenticReactions);
                  },
                );
              },
            ),
          ),
          if (_replyingToName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey.shade200,
              child: Row(
                children: [
                  Text("Replying to $_replyingToName...", style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _replyingToName = null),
                    child: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
            decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentCtrl,
                    focusNode: _commentFocus,
                    decoration: InputDecoration(
                      hintText: "Write a comment...",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: AppColors.primaryPurple),
                  onPressed: _submitComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacebookStyleComment(String commentId, Map<String, dynamic> data, Map<String, dynamic> authenticReactions) {
    String myReact = authenticReactions[FirebaseAuth.instance.currentUser?.uid] ?? '';
    bool isMine = data['authorId'] == FirebaseAuth.instance.currentUser?.uid;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🚀 REAL-TIME DYNAMIC COMMENT HEADER 🚀
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(data['authorId']).snapshots(),
            builder: (context, userSnapshot) {
              String displayName = data['authorName'] ?? 'User';
              String displayAvatar = data['authorAvatar'] ?? '';

              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                displayName = userData['name'] ?? displayName;
                displayAvatar = userData['profileImageUrl'] ?? displayAvatar;
              }

              return widget.buildAvatar(displayAvatar, displayName, radius: 18.0);
            }
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GestureDetector(
                      onLongPress: () => _showCommentOptions(commentId, isMine),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(18)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🚀 DYNAMIC COMMENT NAME 🚀
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance.collection('users').doc(data['authorId']).snapshots(),
                              builder: (context, userSnapshot) {
                                String displayName = data['authorName'] ?? 'User';
                                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                                  var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                                  displayName = userData['name'] ?? displayName;
                                }
                                return Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13));
                              }
                            ),
                            const SizedBox(height: 2),
                            data['text'].toString().startsWith('@') 
                              ? RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(text: data['text'].split(' ')[0] + ' ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                                      TextSpan(text: data['text'].substring(data['text'].indexOf(' ') + 1), style: const TextStyle(color: Colors.black)),
                                    ]
                                  )
                                )
                              : Text(data['text'] ?? '', style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                    
                    if (authenticReactions.isNotEmpty)
                      Positioned(
                        bottom: -10,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => widget.showReactionList(authenticReactions),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                            child: Row(
                              children: [
                                ...authenticReactions.values.toSet().take(3).map((e) => Text(e.toString(), style: const TextStyle(fontSize: 12))),
                                const SizedBox(width: 4),
                                Text('${authenticReactions.length}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 4),
                  child: Row(
                    children: [
                      Text(widget.formatTime(data['timestamp']).toString().split(',').last.trim(), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          if (myReact.isEmpty) {
                            widget.showEmoji(commentId, authenticReactions, false, parentPostId: widget.postId); 
                          } else {
                            widget.handleReaction(commentId, authenticReactions, myReact, isPost: false, parentPostId: widget.postId);
                          }
                        },
                        child: Text(myReact.isNotEmpty ? "Reacted" : "React", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: myReact.isNotEmpty ? Colors.blue : Colors.grey.shade600)),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => _startReply(data['authorName']),
                        child: Text("Reply", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submitComment() async {
    if (_commentCtrl.text.trim().isEmpty) return;
    if (FirebaseAuth.instance.currentUser == null) return; 

    final auth = Provider.of<AuthProvider>(context, listen: false);

    String finalComment = _replyingToName != null 
        ? "@$_replyingToName ${_commentCtrl.text.trim()}" 
        : _commentCtrl.text.trim();

    await FirebaseFirestore.instance.collection('posts').doc(widget.postId).collection('comments').add({
      'authorId': FirebaseAuth.instance.currentUser?.uid,
      'authorName': auth.userName ?? 'User',
      'authorAvatar': auth.profileImageUrl ?? '',
      'text': finalComment,
      'timestamp': FieldValue.serverTimestamp(),
      'reactions': {},
    });
    
    _commentCtrl.clear();
    setState(() => _replyingToName = null); 
    _commentFocus.unfocus();
  }
}