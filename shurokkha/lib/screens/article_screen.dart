import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/localization_extension.dart';
import 'home_screen.dart';

class ArticleScreen extends StatefulWidget {
  const ArticleScreen({super.key});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  int _navIndex = 1;
  int _currentTab = 0; // 0: Articles, 1: Favorites
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _sortBy = 'Newest';
  late SharedPreferences _prefs;
  Set<String> _favoriteArticleIds = {};
  List<String> _recentlyViewed = [];

  final Map<String, Color> _categoryColors = {
    'All': const Color(0xFF9B59B6),
    'Health': const Color(0xFFE91E63),
    'Wellness': const Color(0xFF4CAF50),
    'Mental Health': const Color(0xFF2196F3),
    'Education': const Color(0xFF9C27B0),
    'Nutrition': const Color(0xFFFF9800),
    'Sustainability': const Color(0xFF00BCD4),
  };

  final List<String> _categories = [
    'All',
    'Health',
    'Wellness',
    'Mental Health',
    'Education',
    'Nutrition',
    'Sustainability'
  ];

  final List<Map<String, dynamic>> _articles = [
    {
      'id': '1',
      'title': 'Understanding Your Menstrual Cycle',
      'title_bn': 'আপনার Menstrual Cycle বুঝে নিন সহজভাবে',
      'author': 'Dr. Sarah Johnson',
      'date': 'Mar 15, 2024',
      'category': 'Health',
      'category_bn': 'স্বাস্থ্য',
      'icon': Icons.favorite,
      'summary': 'Learn the four phases of your menstrual cycle and how they affect your body and mood.',
      'summary_bn': 'জানুন আপনার Period Cycle এর চার পর্যায় সম্পর্কে। কীভাবে এটি আপনার শরীর, মেজাজ এবং দৈনন্দিন কাজকর্মকে প্রভাবিত করে তা বুঝে নিন সহজ ভাষায়।',
      'readTime': '8 min',
      'url': 'https://www.healthline.com/health/womens-health/menstrual-cycle',
    },
    {
      'id': '2',
      'title': 'Period Myths Debunked',
      'title_bn': 'Period নিয়ে যত সব ভুল ধারণা - সত্য জেনে নিন',
      'author': 'Health Expert Team',
      'date': 'Mar 12, 2024',
      'category': 'Education',
      'category_bn': 'শিক্ষা',
      'icon': Icons.lightbulb,
      'summary': 'Discover the truth behind common period myths and misconceptions.',
      'summary_bn': 'Period নিয়ে আমাদের সমাজে যত ভুল ধারণা এবং বিশ্বাস আছে - সেগুলো সম্পর্কে সত্যি কথা জানুন। চিকিৎসকদের কাছ থেকে সরাসরি তথ্য পান।',
      'readTime': '5 min',
      'url': 'https://www.plannedparenthood.org/learn/health-and-wellness/menstruation',
    },
    {
      'id': '3',
      'title': 'Natural Remedies for Period Pain',
      'title_bn': 'Period Pain এর সহজ প্রাকৃতিক সমাধান',
      'author': 'Dr. Emily Chen',
      'date': 'Mar 10, 2024',
      'category': 'Wellness',
      'category_bn': 'সুস্থতা',
      'icon': Icons.eco,
      'summary': 'Explore natural ways to manage period pain without medication.',
      'summary_bn': 'Period এর ব্যথা সামলানোর জন্য ওষুধের পাশাপাশি প্রাকৃতিক উপায় জানুন। ঘর বসেই যা করতে পারেন - hot water bag, ম্যাসেজ, যোগব্যায়াম এবং আরও অনেক কিছু।',
      'readTime': '6 min',
      'url': 'https://www.healthline.com/health/womens-health/period-pain-relief',
    },
    {
      'id': '4',
      'title': 'Nutrition Tips for Better Cycles',
      'title_bn': 'সঠিক খাবার খান, পিরিয়ডকে করুন আরো নিয়ন্ত্রিত',
      'author': 'Nutritionist Lisa Brown',
      'date': 'Mar 8, 2024',
      'category': 'Nutrition',
      'category_bn': 'পুষ্টি',
      'icon': Icons.restaurant,
      'summary': 'Find out which foods can help regulate your cycle and boost energy.',
      'summary_bn': 'কোন কোন খাবার খেলে আপনার Menstrual Cycle হবে নিয়মিত এবং আপনি থাকবেন আরো সুস্থ ও সবল? জানুন সুপারফুড এবং পুষ্টিকর খাবারের গল্প যা আপনার জন্য দারুণ কাজ করবে।',
      'readTime': '7 min',
      'url': 'https://www.mayoclinic.org/diseases-conditions/menstruation/nutrition',
    },
    {
      'id': '5',
      'title': 'Mental Health & Your Cycle',
      'title_bn': 'আপনার Cycle এবং মেজাজ - এর মধ্যে সম্পর্ক কী?',
      'author': 'Dr. Michael Torres',
      'date': 'Mar 5, 2024',
      'category': 'Mental Health',
      'category_bn': 'মানসিক স্বাস্থ্য',
      'icon': Icons.psychology,
      'summary': 'Understanding the connection between your cycle and emotional wellbeing.',
      'summary_bn': 'কেন মাসের নির্দিষ্ট দিনে আপনি খুব রেগে যান বা দুঃখবোধ করেন? জানুন আপনার Period Cycle এবং আবেগের সম্পর্ক কেন এত গভীর, এবং কীভাবে নিজেকে আরো ভালো রাখা যায়।',
      'readTime': '9 min',
      'url': 'https://www.psychologytoday.com/menstrual-cycle-mood',
    },
    {
      'id': '6',
      'title': 'Eco-Friendly Period Products',
      'title_bn': 'পরিবেশ রাখুন ভালো, নিজেও থাকুন নিরাপদ',
      'author': 'Sustainability Advisor Kate',
      'date': 'Mar 1, 2024',
      'category': 'Sustainability',
      'category_bn': 'পরিবেশ',
      'icon': Icons.eco,
      'summary': 'Make environmentally conscious choices for your period management.',
      'summary_bn': 'পরিবেশের জন্য ক্ষতিকর না করে কীভাবে আপনার Period Management করবেন? জানুন Reusable Pads, Menstrual Cup এর মতো পরিবেশবান্ধব পণ্যগুলো সম্পর্কে এবং তাদের সুবিধা।',
      'readTime': '4 min',
      'url': 'https://www.greenmatters.com/sustainability/menstrual-products',
    },
    {
      'id': '7',
      'title': 'PMS vs PMDD: What\'s the Difference?',
      'title_bn': 'PMS বনাম PMDD - জানুন পার্থক্য এবং সমাধান',
      'author': 'Dr. Jennifer Park',
      'date': 'Feb 28, 2024',
      'category': 'Health',
      'category_bn': 'স্বাস্থ্য',
      'icon': Icons.info_outline,
      'summary': 'Learn to distinguish between common period symptoms and PMDD concerns.',
      'summary_bn': 'সাধারণ Period এর আগে যে উপসর্গ হয় তা কি শুধু PMS নাকি PMDD? জানুন দুটোর মধ্যে পার্থক্য কি, এবং কখন আপনার ডাক্তারের কাছে যাওয়া উচিত।',
      'readTime': '10 min',
      'url': 'https://www.healthline.com/health/pms-vs-pmdd',
    },
    {
      'id': '8',
      'title': 'Exercise During Your Menstrual Cycle',
      'title_bn': 'Period এর সময় কীভাবে ব্যায়াম করবেন - সম্পূর্ণ গাইড',
      'author': 'Fitness Coach Alex',
      'date': 'Feb 25, 2024',
      'category': 'Wellness',
      'category_bn': 'সুস্থতা',
      'icon': Icons.fitness_center,
      'summary': 'Optimize your workout routine based on your cycle phases.',
      'summary_bn': 'Period চলার সময় কি সত্যি ব্যায়াম করা যায়? হ্যাঁ, তবে সঠিক নিয়মে। জানুন Cycle এর প্রতিটি পর্যায়ে কী ধরনের ব্যায়াম করা সবচেয়ে ভালো এবং কেন।',
      'readTime': '7 min',
      'url': 'https://www.healthline.com/health/fitness/period-exercise-guide',
    },
  ];

  final List<Map<String, dynamic>> _dailyTips = [
    {
      'tip':
          'আপনার শরীরকে Hydrated রাখুন! প্রচুর পানি খেলে Bloating এবং Period Cramps অনেক কমে যায়।',
      'emoji': '💧',
      'color': const Color(0xFF64B5F6),
    },
    {
      'tip':
          'নিয়মিত ব্যায়াম করুন। এটি আপনার Period Cycle কে নিয়মিত রাখে এবং Period Pain প্রাকৃতিকভাবে কমায়।',
      'emoji': '🏃',
      'color': const Color(0xFF4CAF50),
    },
    {
      'tip':
          'গভীর শ্বাস-প্রশ্বাসের ব্যায়াম করুন। এটি Stress কমায় এবং Period সম্পর্কিত Anxiety দূর করতে সাহায্য করে।',
      'emoji': '🧘',
      'color': const Color(0xFF9C27B0),
    },
    {
      'tip':
          'লৌহযুক্ত খাবার খান যেমন পালংশাক এবং ডাল। এগুলো Period এর সময়ে দুর্বলতা কমাতে সাহায্য করে।',
      'emoji': '🥗',
      'color': const Color(0xFFFF7043),
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializePreferences();
  }

  Future<void> _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadFavorites();
    _loadRecentlyViewed();
  }

  void _loadFavorites() {
    final favs = _prefs.getStringList('bookmarked_articles') ?? [];
    setState(() => _favoriteArticleIds = favs.toSet());
  }

  void _loadRecentlyViewed() {
    final viewed = _prefs.getStringList('recently_viewed_articles') ?? [];
    setState(() => _recentlyViewed = viewed);
  }

  Future<void> _toggleBookmark(String articleId) async {
    setState(() {
      if (_favoriteArticleIds.contains(articleId)) {
        _favoriteArticleIds.remove(articleId);
      } else {
        _favoriteArticleIds.add(articleId);
      }
    });
    await _prefs.setStringList(
        'bookmarked_articles', _favoriteArticleIds.toList());
  }

  Future<void> _addToRecentlyViewed(String articleId) async {
    _recentlyViewed.removeWhere((id) => id == articleId);
    _recentlyViewed.insert(0, articleId);
    if (_recentlyViewed.length > 10) _recentlyViewed.removeLast();
    await _prefs.setStringList('recently_viewed_articles', _recentlyViewed);
  }

  List<Map<String, dynamic>> _getFilteredArticles() {
    var filtered = _articles;

    if (_selectedCategory != 'All') {
      filtered =
          filtered.where((a) => a['category'] == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((a) =>
              a['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
              a['summary'].toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_sortBy == 'Oldest') {
      filtered.sort((a, b) => b['date'].compareTo(a['date']));
    } else if (_sortBy == 'Short Reads') {
      filtered.sort((a, b) {
        int timeA = int.parse(a['readTime'].split(' ')[0]);
        int timeB = int.parse(b['readTime'].split(' ')[0]);
        return timeA.compareTo(timeB);
      });
    }

    return filtered;
  }

  List<Map<String, dynamic>> _getFavoriteArticles() {
    return _articles
        .where((a) => _favoriteArticleIds.contains(a['id']))
        .toList();
  }

  Future<void> _openArticle(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _shareArticle(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Shared: $title'),
        backgroundColor: AppColors.primaryPurple,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildDailyTipCard() {
    final today = DateTime.now().day % _dailyTips.length;
    final tip = _dailyTips[today];
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tip['color'].withValues(alpha: 0.8),
            tip['color'].withValues(alpha: 0.4)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(tip['emoji'], style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.translate('daily_tip'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            tip['tip'],
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticlesTab() {
    final filtered = _getFilteredArticles();
    return Column(
      children: [
        _buildDailyTipCard(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: context.translate('search_articles'),
              prefixIcon:
                  const Icon(Icons.search_outlined, color: AppColors.textGrey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.softLavender),
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.7),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(cat),
                    onSelected: (selected) =>
                        setState(() => _selectedCategory = cat),
                    backgroundColor: Colors.white,
                    selectedColor: _categoryColors[cat]?.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? _categoryColors[cat]
                          : AppColors.textGrey,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.translate('sort_by_label'),
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textGrey),
              ),
              DropdownButton<String>(
                value: _sortBy,
                items: ['Newest', 'Oldest', 'Short Reads']
                    .map((sort) =>
                        DropdownMenuItem(value: sort, child: Text(sort)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _sortBy = value ?? 'Newest'),
                underline: const SizedBox(),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off,
                          size: 48,
                          color: AppColors.textGrey.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      const Text('No articles found',
                          style: TextStyle(color: AppColors.textGrey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _ArticleCard(
                      article: filtered[index],
                      isBookmarked:
                          _favoriteArticleIds.contains(filtered[index]['id']),
                      onBookmark: () => _toggleBookmark(filtered[index]['id']),
                      onRead: () {
                        _addToRecentlyViewed(filtered[index]['id']);
                        _openArticle(filtered[index]['url']);
                      },
                      onShare: () => _shareArticle(filtered[index]['title']),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFavoritesTab() {
    final favorites = _getFavoriteArticles();
    return favorites.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_outline,
                    size: 64, color: AppColors.textGrey.withValues(alpha: 0.5)),
                const SizedBox(height: 12),
                const Text(
                  'No saved articles yet',
                  style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textGrey,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Bookmark articles to save them here',
                  style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              return _ArticleCard(
                article: favorites[index],
                isBookmarked: true,
                onBookmark: () => _toggleBookmark(favorites[index]['id']),
                onRead: () {
                  _addToRecentlyViewed(favorites[index]['id']);
                  _openArticle(favorites[index]['url']);
                },
                onShare: () => _shareArticle(favorites[index]['title']),
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        colors: const [
          Color(0xFFEDD9FF),
          Color(0xFFF0E0FF),
          Color(0xFFFFE6F5),
          Color(0xFFE8D5FF)
        ],
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.translate('health_articles'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                  height: 1, color: AppColors.textGrey.withValues(alpha: 0.2)),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _currentTab = 0),
                        child: Column(
                          children: [
                            Text(
                              'Articles',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: _currentTab == 0
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: _currentTab == 0
                                    ? AppColors.primaryPurple
                                    : AppColors.textGrey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (_currentTab == 0)
                              Container(
                                height: 2,
                                color: AppColors.primaryPurple,
                              )
                            else
                              const SizedBox(height: 2),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _currentTab = 1),
                        child: Column(
                          children: [
                            Text(
                              'Saved (${_favoriteArticleIds.length})',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: _currentTab == 1
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: _currentTab == 1
                                    ? AppColors.primaryPurple
                                    : AppColors.textGrey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (_currentTab == 1)
                              Container(
                                height: 2,
                                color: AppColors.primaryPurple,
                              )
                            else
                              const SizedBox(height: 2),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _currentTab == 0
                    ? _buildArticlesTab()
                    : _buildFavoritesTab(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _navIndex,
        onTap: (i) {
          if (i == _navIndex) return;
          switch (i) {
            case 0:
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const Scaffold()));
              break;
            case 1:
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const Scaffold()));
              break;
            case 2:
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const Scaffold()));
              break;
            case 3:
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const Scaffold()));
              break;
            case 4:
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const Scaffold()));
              break;
          }
          setState(() => _navIndex = i);
        },
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final Map<String, dynamic> article;
  final bool isBookmarked;
  final VoidCallback onBookmark;
  final VoidCallback onRead;
  final VoidCallback onShare;

  const _ArticleCard({
    required this.article,
    required this.isBookmarked,
    required this.onBookmark,
    required this.onRead,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(article['category']);
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child:
                        Icon(article['icon'], color: categoryColor, size: 28),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          article['category'],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: categoryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.schedule_outlined,
                              size: 14,
                              color: AppColors.textGrey.withValues(alpha: 0.7)),
                          const SizedBox(width: 4),
                          Text(
                            article['readTime'],
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textGrey.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            article['date'],
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textGrey.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onBookmark,
                  child: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                    color: isBookmarked ? categoryColor : AppColors.textGrey,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              article['title_bn'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              article['summary_bn'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textGrey,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'By ${article['author']}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onShare,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.share_outlined,
                        size: 16, color: AppColors.textGrey),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onRead,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Read',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: categoryColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward,
                            size: 14, color: categoryColor),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final Map<String, Color> colors = {
      'Health': const Color(0xFFE91E63),
      'Wellness': const Color(0xFF4CAF50),
      'Mental Health': const Color(0xFF2196F3),
      'Education': const Color(0xFF9C27B0),
      'Nutrition': const Color(0xFFFF9800),
      'Sustainability': const Color(0xFF00BCD4),
      'All': const Color(0xFF9B59B6),
    };
    return colors[category] ?? const Color(0xFF9B59B6);
  }
}
