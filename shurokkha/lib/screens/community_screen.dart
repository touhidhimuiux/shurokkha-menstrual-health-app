import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/localization_extension.dart';
import 'home_screen.dart';
import 'period_tracker_screen.dart';
import 'chat_screen.dart';
import 'shop_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  String _selectedFilter = 'All';

  final List<String> _filterChips = [
    'সব',
    'পিরিয়ড',
    'মানসিক স্বাস্থ্য',
  ];

  late List<Map<String, dynamic>> _posts;

  @override
  void initState() {
    super.initState();
    _posts = [
      {
        'id': '2487',
        'phase': 'পিরিয়ড',
        'phaseEmoji': '🩸',
        'mood': '😭',
        'content': 'দ্বিতীয় দিনের ক্র্যাম্প ভীষণ 😭 কোন টিপস আছে?',
        'category': 'পিরিয়ড',
        'supports': 156,
        'comments': [
          {'text': 'হিটিং প্যাড ব্যবহার করার চেষ্টা করুন এবং হাইড্রেটেড থাকুন!', 'time': '১ ঘণ্টা আগে'},
          {'text': 'ম্যাগনেসিয়াম সাপ্লিমেন্ট আমাকে সাহায্য করেছে', 'time': '२ ঘণ্টা আগে'},
          {'text': 'মৃদু যোগ স্ট্রেচ অসাধারণ কাজ করে', 'time': '२ ঘণ্টা আগে'},
        ],
        'saves': 18,
        'time': '२ ঘণ্টা আগে',
        'isExpertReply': false,
      },
      {
        'id': '3294',
        'phase': 'ফলিকুলার পর্যায়',
        'phaseEmoji': '💪',
        'mood': '🤔',
        'content':
            'আমার ফলিকুলার ফেজে নতুন ওয়ার্কআউট রুটিন শুরু করেছি। ইতিমধ্যে আরও শক্তিশালী অনুভব করছি!',
        'category': 'মানসিক স্বাস্থ্য',
        'supports': 312,
        'comments': [
          {'text': 'এটি অসাধারণ! চালিয়ে যান 💪', 'time': '३ ঘণ্টা আগে'},
          {'text': 'আমিও এটি লক্ষ্য করেছি! প্রশিক্ষণের সেরা সময়', 'time': '५ ঘণ্টা আগে'}
        ],
        'saves': 89,
        'time': '८ ঘণ্টা আগে',
        'isExpertReply': false,
      },
      {
        'id': '5892',
        'phase': 'পিরিয়ড',
        'phaseEmoji': '🩸',
        'mood': '😔',
        'content':
            'আমার পিরিয়ডের সময় ক্লান্ত এবং আবেগপূর্ণ বোধ করছি। এটি কি স্বাভাবিক?',
        'category': 'পিরিয়ড',
        'supports': 234,
        'comments': [
          {'text': 'সম্পূর্ণরূপে স্বাভাবিক! আপনি একা নন 💜', 'time': '१ ঘণ্টা আগে', 'isExpert': true},
          {'text': 'আমার সাথেও একই, বিশ্রাম গুরুত্বপূর্ণ', 'time': '४ ঘণ्টा আগে'}
        ],
        'saves': 45,
        'time': '५ ঘণ্টা আগে',
        'isExpertReply': true,
      },
      {
        'id': '7156',
        'phase': 'ফলিকুলার পর্যায়',
        'phaseEmoji': '💪',
        'mood': '😌',
        'content':
            'মানসিক স্বাস্থ্য টিপ: ব্যায়াম আমার উদ্বেগের জন্য গেম-চেঞ্জার হয়েছে। অত্যন্ত সুপারিশ করছি!',
        'category': 'মানসিক স্বাস্থ্য',
        'supports': 198,
        'comments': [
          {'text': 'ব্যায়াম আমাকেও অনেক সাহায্য করেছে!',' time': '२ ঘণ्টा आगे', 'isExpert': true}
        ],
        'saves': 55,
        'time': '१० ঘণ्टा आগे',
        'isExpertReply': true,
      },
    ];
  }

  void _showCommentsDialog(BuildContext context, Map<String, dynamic> post) {
    final TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SizedBox(
          height: 600,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Shared Experiences',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: AppColors.textGrey),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${post['comments'].length} people have shared their experience',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),

              // Comments List
              Expanded(
                child: ListView.builder(
                  itemCount: post['comments'].length,
                  itemBuilder: (context, index) {
                    final comment = post['comments'][index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primaryPurple
                                            .withValues(alpha: 0.7),
                                        AppColors.softPink.withValues(alpha: 0.7),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'U',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Anonymous User',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                          if (comment['isExpert'] == true) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 4, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade50,
                                                borderRadius: BorderRadius.circular(3),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.verified,
                                                      color: Colors.blue, size: 10),
                                                  SizedBox(width: 2),
                                                  Text(
                                                    'Expert',
                                                    style: TextStyle(
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        comment['time'],
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              comment['text'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textDark,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),

              // Add Comment Input
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: 'Share your experience… (anonymous)',
                  hintStyle: const TextStyle(color: AppColors.textGrey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.softLavender,
                    ),
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      if (commentController.text.isNotEmpty) {
                        setState(() {
                          post['comments'].add({
                            'text': commentController.text,
                            'time': 'now',
                            'isExpert': false,
                          });
                        });
                        Navigator.pop(context);
                        commentController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Your experience shared anonymously!'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: commentController.text.isEmpty
                            ? Colors.grey.shade300
                            : AppColors.primaryPurple,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        color: commentController.text.isEmpty
                            ? Colors.grey.shade600
                            : Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                maxLines: 3,
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredPosts = _selectedFilter == 'All'
        ? _posts
        : _posts.where((post) => post['category'] == _selectedFilter).toList();

    return Scaffold(
      bottomNavigationBar: AppBottomNav(
        currentIndex: 4,
        onTap: (i) {
          if (i == 4) return;

          switch (i) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const PeriodTrackerScreen()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ChatScreen()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ShopScreen()),
              );
              break;
          }
        },
      ),
      body: GradientBackground(
        colors: const [
          Colors.white,
          Colors.white,
          Colors.white,
          Colors.white
        ],
        child: SafeArea(
          child: Column(
            children: [
              // Header with Privacy Badge
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HomeScreen(),
                              ),
                            );
                          },
                          child: const Icon(Icons.arrow_back,
                              color: AppColors.textDark, size: 28),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.translate('community'),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock_outline,
                                  color: Colors.green, size: 14),
                              SizedBox(width: 4),
                              Text(
                                '100% Anonymous',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Search Bar
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search cramps, mood swings…',
                        hintStyle: const TextStyle(color: AppColors.textGrey),
                        prefixIcon:
                            const Icon(Icons.search, color: AppColors.textGrey),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),

              // Safe Space Message
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.softPink.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.softPink.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.favorite, color: AppColors.softPink, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You are not alone 💜 1.2k people feel the same today',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Filter Chips
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: _filterChips.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedFilter = filter);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryPurple
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryPurple
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              filter,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Posts Feed
              Expanded(
                child: filteredPosts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.favorite_outline,
                                size: 48, color: AppColors.textGrey),
                            const SizedBox(height: 12),
                            Text(
                              'No posts yet in "$_selectedFilter"',
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        itemCount: filteredPosts.length,
                        itemBuilder: (context, index) {
                          return _CommunityPostCard(
                            post: filteredPosts[index],
                            onShare: _showCommentsDialog,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePostDialog(context),
        backgroundColor: AppColors.primaryPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Share',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    String selectedMood = '😊';
    final TextEditingController contentController = TextEditingController();
    String selectedCategory = 'Period';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Share Your Experience',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mood selector
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'How are you feeling?',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: ['😊', '😭', '😡', '🤔', '😴'].map((emoji) {
                          return GestureDetector(
                            onTap: () => setState(() => selectedMood = emoji),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: selectedMood == emoji
                                    ? AppColors.primaryPurple.withValues(alpha: 0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                emoji,
                                style: TextStyle(
                                  fontSize: selectedMood == emoji ? 32 : 28,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const Divider(),

                // Category selector
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: ['Period', 'Mental Health'].map((category) {
                          return GestureDetector(
                            onTap: () => setState(() => selectedCategory = category),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: selectedCategory == category
                                    ? AppColors.primaryPurple
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: selectedCategory == category
                                      ? Colors.white
                                      : AppColors.textDark,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const Divider(),

                // Content input
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your message',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: contentController,
                      decoration: InputDecoration(
                        hintText: 'Share your experience… (100% anonymous)',
                        hintStyle: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primaryPurple,
                          ),
                        ),
                        contentPadding:
                            const EdgeInsets.all(12),
                      ),
                      maxLines: 4,
                      onChanged: (value) => setState(() {}),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textGrey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: contentController.text.isEmpty
                  ? null
                  : () {
                      // Add new post to the beginning
                      final newPost = {
                        'id': DateTime.now().millisecondsSinceEpoch.toString(),
                        'phase': selectedMood == '💪' ? 'Follicular' : 'Period',
                        'phaseEmoji': selectedMood == '😴' ? '🩸' : selectedMood,
                        'mood': selectedMood,
                        'content': contentController.text,
                        'category': selectedCategory,
                        'supports': 0,
                        'comments': [],
                        'saves': 0,
                        'time': 'now',
                        'isExpertReply': false,
                      };

                      setState(() {
                        _posts.insert(0, newPost);
                      });

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Your experience shared anonymously! 💜'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
              child: const Text(
                'Share Anonymously',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityPostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final Function(BuildContext, Map<String, dynamic>) onShare;

  const _CommunityPostCard({
    required this.post,
    required this.onShare,
  });

  @override
  State<_CommunityPostCard> createState() => _CommunityPostCardState();
}

class _CommunityPostCardState extends State<_CommunityPostCard> {
  late int _supports;
  bool _isSupported = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _supports = widget.post['supports'];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Anonymous User & Phase Tag
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Anonymous Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryPurple.withValues(alpha: 0.7),
                        AppColors.softPink.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'User_${widget.post['id']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (widget.post['isExpertReply'])
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified,
                                      color: Colors.blue, size: 12),
                                  SizedBox(width: 2),
                                  Text(
                                    'Expert',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${widget.post['phaseEmoji']} ${widget.post['phase']}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            widget.post['time'],
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert_outlined,
                      color: AppColors.textGrey, size: 20),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.flag_outlined,
                                  color: Colors.red),
                              title: const Text('Report',
                                  style: TextStyle(color: Colors.red)),
                              onTap: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Post reported'),
                                      backgroundColor: Colors.orange),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Mood Emoji & Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post['mood'],
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.post['content'],
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textDark,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Divider(height: 1),
          ),

          // Interaction Buttons (Support, Comment, Save, Report)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Support Button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isSupported = !_isSupported;
                      _supports += _isSupported ? 1 : -1;
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        _isSupported ? Icons.favorite : Icons.favorite_outline,
                        color: _isSupported
                            ? AppColors.softPink
                            : AppColors.textGrey,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _supports.toString(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _isSupported
                              ? AppColors.softPink
                              : AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),

                // Comment Button
                GestureDetector(
                  onTap: () => widget.onShare(context, widget.post),
                  child: Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline,
                          color: AppColors.textGrey, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.post['comments'].length}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),

                // Save Button
                GestureDetector(
                  onTap: () {
                    setState(() => _isSaved = !_isSaved);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_isSaved
                            ? 'Post saved'
                            : 'Post removed from saved'),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(
                        _isSaved ? Icons.bookmark : Icons.bookmark_outline,
                        color: _isSaved
                            ? AppColors.primaryPurple
                            : AppColors.textGrey,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _isSaved
                              ? AppColors.primaryPurple
                              : AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
