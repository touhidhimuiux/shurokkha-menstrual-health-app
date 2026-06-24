import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/localization_extension.dart';
import '../services/language_provider.dart';
import '../utils/responsive.dart';
import 'home_screen.dart';
import 'period_tracker_screen.dart';
import 'chat_screen.dart';
import 'community_feed_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final Set<int> _favoriteProducts = {};

  final List<String> _categories = ['All', 'Pads', 'Cups', 'Wellness', 'Hygiene', 'Nutrition'];
  
  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Ultra Comfort Pads',
      'name_bn': 'অতি আরামদায়ক প্যাড',
      'category': 'Pads',
      'currency': '৳',
      'icon': Icons.article,
      'image': 'assets/product_pad.png',
      'badge': 'Best Seller',
      'badge_bn': 'সবচেয়ে জনপ্রিয়',
      'description': 'Ultra-soft wings with excellent absorbency for day protection',
      'description_bn': 'দিনের সুরক্ষার জন্য অতি নরম ডানা এবং চমৎকার শোষণক্ষমতা',
      'benefits': 'Extra comfort & leak protection',
      'benefits_bn': 'অতিরিক্ত আরাম এবং  সুরক্ষা',
      'links': {
        'Shajgoj': 'https://shop.shajgoj.com',
        'Chaldal': 'https://chaldal.com',
        'Othoba': 'https://othoba.com',
        'Arogga': 'https://arogga.com',
      },
    },
    {
      'name': 'Menstrual Cup',
      'name_bn': 'Period Cup',
      'category': 'Cups',
      'currency': '৳',
      'icon': Icons.water_drop,
      'image': 'assets/cup.png',
      'badge': 'Recommended',
      'badge_bn': 'পরামর্শকৃত',
      'description': 'Reusable medical-grade silicone cup for up to 12 hours protection',
      'description_bn': '১२ ঘন্টা পর্যন্ত সুরক্ষার জন্য পুনর্ব্যবহারযোগ্য চিকিৎসা সিলিকন কাপ',
      'benefits': 'Eco-friendly & cost-effective',
      'benefits_bn': 'পরিবেশ বান্ধব এবং সাশ্রয়ী',
      'links': {
        'Niru Cup': 'https://nirucup.com',
        'Menstrual Cup BD': 'https://menstrualcupbd.com',
        'Daraz': 'https://www.daraz.com.bd',
      },
    },
    {
      'name': 'Night Pads',
      'name_bn': 'রাতের প্যাড',
      'category': 'Pads',
      'currency': '৳',
      'icon': Icons.article,
      'image': 'assets/night_pad.png',
      'badge': null,
      'description': 'Extended protection for night-time use, up to 10 hours',
      'description_bn': 'রাতের ব্যবহারের জন্য বর্ধিত সুরক্ষা, ১০ ঘন্টা পর্যন্ত',
      'benefits': 'Secure overnight protection',
      'benefits_bn': 'নিরাপদ রাত্রিকালীন সুরক্ষা',
      'links': {
        'ePharma': 'https://epharma.com.bd',
        'Osudpotro': 'https://osudpotro.com',
        'Shombhob': 'https://shombhob.com',
        'Daraz': 'https://www.daraz.com.bd',
      },
    },
    {
      'name': 'Pain Relief Kit',
      'name_bn': 'ব্যথা ত্রাণ প্যাকেজ',
      'category': 'Wellness',
      'currency': '৳',
      'icon': Icons.favorite,
      'image': 'assets/period_kit.png',
      'badge': 'Recommended for PMS Relief',
      'badge_bn': 'PMS ত্রাণের জন্য পরামর্শকৃত',
      'description': 'Natural ingredients for effective cramp & PMS relief',
      'description_bn': 'কার্যকর ক্র্যাম্প এবং PMS ত্রাণের জন্য প্রাকৃতিক উপাদান',
      'benefits': 'Fast-acting pain relief',
      'benefits_bn': 'দ্রুত কাজ করা ব্যথা ত্রাণ',
      'links': {
        'Arogga': 'https://arogga.com',
        'MedEasy': 'https://medeasy.health',
        'Daraz': 'https://www.daraz.com.bd',
      },
    },
    {
      'name': 'Heating Pad',
      'name_bn': 'হিটিং প্যাড',
      'category': 'Wellness',
      'currency': '৳',
      'icon': Icons.thermostat,
      'image': null,
      'badge': 'Best Seller',
      'badge_bn': 'সবচেয়ে জনপ্রিয়',
      'description': 'Electric heating pad with adjustable temperature control',
      'description_bn': 'সামঞ্জস্যযোগ্য তাপমাত্রা নিয়ন্ত্রণ সহ বৈদ্যুতিক হিটিং প্যাড',
      'benefits': 'Muscle relaxation & pain relief',
      'benefits_bn': 'পেশী শিথিলতা এবং ব্যথা ত্রাণ',
      'links': {
        'Daraz': 'https://www.daraz.com.bd',
        'Othoba': 'https://othoba.com',
      },
    },
    {
      'name': 'Period Panties',
      'name_bn': 'পিরিয়ড প্যান্টি',
      'category': 'Hygiene',
      'currency': '৳',
      'icon': Icons.checkroom,
      'image': null,
      'badge': 'Best Seller',
      'badge_bn': 'সবচেয়ে জনপ্রিয়',
      'description': 'Leak-proof period underwear for comfort and confidence',
      'description_bn': 'আরাম এবং আত্মবিশ্বাসের জন্য লিক-প্রুফ পিরিয়ড আন্ডারওয়্যার',
      'benefits': 'All-day protection & comfort',
      'benefits_bn': 'সারাদিন সুরক্ষা এবং আরাম',
      'links': {
        'Daraz': 'https://www.daraz.com.bd',
        'Othoba': 'https://othoba.com',
        'Shombhob': 'https://shombhob.com',
      },
    },
    {
      'name': 'Feminine Wash',
      'name_bn': 'ফেমিনিন ওয়াশ',
      'category': 'Hygiene',
      'currency': '৳',
      'icon': Icons.water,
      'image': null,
      'badge': null,
      'description': 'pH-balanced intimate wash with natural ingredients',
      'description_bn': 'প্রাকৃতিক উপাদান সহ pH-ভারসাম্যযুক্ত ইন্টিমেট ওয়াশ',
      'benefits': 'Gentle cleansing & fresh feeling',
      'benefits_bn': 'মৃদু পরিষ্কার এবং সতেজ অনুভূতি',
      'links': {
        'Shajgoj': 'https://shop.shajgoj.com',
        'Arogga': 'https://arogga.com',
        'Daraz': 'https://www.daraz.com.bd',
      },
    },
    {
      'name': 'Iron Supplement',
      'name_bn': 'আয়রন সাপ্লিমেন্ট',
      'category': 'Nutrition',
      'currency': '৳',
      'icon': Icons.local_pharmacy,
      'image': null,
      'badge': 'Recommended',
      'badge_bn': 'পরামর্শকৃত',
      'description': 'Iron supplement to combat menstrual blood loss',
      'description_bn': 'মাসিক রক্তপাত মোকাবেলা করার জন্য আয়রন সাপ্লিমেন্ট',
      'benefits': 'Combat anemia & boost energy',
      'benefits_bn': 'অ্যানিমিয়া দূর করুন এবং শক্তি বৃদ্ধি করুন',
      'links': {
        'Arogga': 'https://arogga.com',
        'Osudpotro': 'https://osudpotro.com',
        'ePharma': 'https://epharma.com.bd',
      },
    },
    {
      'name': 'Period Tea',
      'name_bn': 'Period চা',
      'category': 'Nutrition',
      'currency': '৳',
      'icon': Icons.local_cafe,
      'image': null,
      'badge': 'Best Seller',
      'badge_bn': 'সবচেয়ে জনপ্রিয়',
      'description': 'Herbal blend to ease cramps and reduce discomfort',
      'description_bn': 'ক্র্যাম্প কমাতে এবং অস্বস্তি হ্রাস করতে জৈব মিশ্রণ',
      'benefits': 'Natural cramp relief & relaxation',
      'benefits_bn': 'প্রাকৃতিক ক্র্যাম্প ত্রাণ এবং শিথিলতা',
      'links': {
        'Daraz': 'https://www.daraz.com.bd',
        'Shombhob': 'https://shombhob.com',
        'Arogga': 'https://arogga.com',
      },
    },
    {
      'name': 'Vitamin B Complex',
      'name_bn': 'Vitamin B Complex',
      'category': 'Nutrition',
      'currency': '৳',
      'icon': Icons.health_and_safety,
      'image': null,
      'badge': null,
      'description': 'B vitamins to manage PMS symptoms and mood swings',
      'description_bn': 'PMS লক্ষণ এবং মেজাজ পরিবর্তন পরিচালনা করতে B ভিটামিন',
      'benefits': 'Mood support & energy boost',
      'benefits_bn': 'মেজাজ সমর্থন এবং শক্তি বৃদ্ধি',
      'links': {
        'Arogga': 'https://arogga.com',
        'MedEasy': 'https://medeasy.health',
        'Osudpotro': 'https://osudpotro.com',
      },
    },
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    List<Map<String, dynamic>> filtered = _products;
    
    if (_selectedCategory != 'All') {
      filtered = filtered.where((p) => p['category'] == _selectedCategory).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((p) {
            final name = p['name'].toString().toLowerCase();
            final nameBn = (p['name_bn'] ?? '').toString().toLowerCase();
            return name.contains(_searchQuery.toLowerCase()) || 
                   nameBn.contains(_searchQuery.toLowerCase());
          })
          .toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsivePadding(mobilePadding: 16),
                vertical: context.responsivePadding(mobilePadding: 12),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
                        ]
                      ),
                      child: Icon(Icons.arrow_back, color: AppColors.textDark, size: context.responsiveIconSize(mobileSize: 24)),
                    ),
                  ),
                  SizedBox(width: context.responsiveSpacing(mobileSpacing: 16)),
                  Expanded(
                    child: Text(
                      context.translate('shop'),
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(mobileSize: 20, tabletSize: 22),
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsivePadding(mobilePadding: 16),
                vertical: context.responsivePadding(mobilePadding: 8)
              ),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ]
                ),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search for pads, cups, wellness...',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: AppColors.primaryPurple.withOpacity(0.7)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.responsiveBorderRadius(mobileRadius: 16)),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: context.responsivePadding(mobilePadding: 14)),
                  ),
                ),
              ),
            ),

            // Category Filter
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: context.responsivePadding(mobilePadding: 12)),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category == _selectedCategory;
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: context.responsiveSpacing(mobileSpacing: 6)),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedCategory = category),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryPurple : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryPurple : Colors.grey.shade300,
                            ),
                            boxShadow: isSelected ? [
                              BoxShadow(color: AppColors.primaryPurple.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
                            ] : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textDark,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              fontSize: context.responsiveFontSize(mobileSize: 13, tabletSize: 14),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Products List (Changed from GridView to dynamic ListView)
            Expanded(
              child: _filteredProducts.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        context.responsivePadding(mobilePadding: 16),
                        context.responsivePadding(mobilePadding: 8),
                        context.responsivePadding(mobilePadding: 16),
                        context.responsivePadding(mobilePadding: 100), // Bottom nav padding
                      ),
                      itemCount: _filteredProducts.length,
                      separatorBuilder: (context, index) => SizedBox(height: context.responsiveSpacing(mobileSpacing: 16)),
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        final isFavorite = _favoriteProducts.contains(index);
                        return _ProductCard(
                          product: product,
                          isFavorite: isFavorite,
                          onFavoriteToggle: () {
                            setState(() {
                              isFavorite ? _favoriteProducts.remove(index) : _favoriteProducts.add(index);
                            });
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 3,
        onTap: (i) {
          if (i == 3) return;
          Widget screen = const HomeScreen();
          if (i == 1) screen = const PeriodTrackerScreen();
          if (i == 2) screen = const ChatScreen();
          if (i == 4) screen = const CommunityFeedScreen();
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => screen));
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.primaryPurple.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.shopping_bag_outlined, size: 48, color: AppColors.primaryPurple.withOpacity(0.6)),
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search term',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const _ProductCard({
    required this.product,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  // Professional Bottom Sheet for purchasing
  void _showPurchaseOptions(BuildContext context, String name, String? image, IconData fallbackIcon, Map<String, String> links) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              
              // Product Header
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.softPink.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: image != null
                        ? Image.asset(image, fit: BoxFit.contain)
                        : Icon(fallbackIcon, color: AppColors.primaryPurple, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Available Options For", style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                        Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textDark),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Store Links List
              ...links.entries.map((entry) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
                      ]),
                      child: Icon(Icons.storefront, color: AppColors.primaryPurple, size: 20),
                    ),
                    title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: const Text("Tap to view in store", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: () async {
                      final Uri uri = Uri.parse(entry.value);
                      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open store link.')));
                      }
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.read<LanguageProvider>().isEnglish;
    final name = isEnglish ? product['name'] : product['name_bn'] ?? product['name'];
    final description = isEnglish ? product['description'] : product['description_bn'] ?? product['description'];
    final benefits = isEnglish ? product['benefits'] : product['benefits_bn'] ?? product['benefits'];
    final badge = isEnglish ? product['badge'] : product['badge_bn'] ?? product['badge'];
    final Map<String, String> links = product['links'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Image Section
            Container(
              width: 130, // Fixed width prevents squeezing
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.softPink.withOpacity(0.4),
                    AppColors.softLavender.withOpacity(0.2),
                  ],
                ),
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: product['image'] != null
                          ? Image.asset(product['image'], fit: BoxFit.contain)
                          : Icon(product['icon'], size: 48, color: AppColors.primaryPurple.withOpacity(0.6)),
                    ),
                  ),
                  if (badge != null)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badge.length > 12 ? '${badge.substring(0, 10)}..' : badge,
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Right Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title and Favorite Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark, height: 1.2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: onFavoriteToggle,
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.redAccent : Colors.grey.shade400,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Description
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.3),
                    ),
                    const SizedBox(height: 8),

                    // Benefits
                    Row(
                      children: [
                        Icon(Icons.verified_rounded, size: 14, color: Colors.green.shade500),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            benefits,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11, color: Colors.green.shade700, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Elegant Shop Now Button
                    SizedBox(
                      width: double.infinity,
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () => _showPurchaseOptions(context, name, product['image'], product['icon'], links),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple.withOpacity(0.08),
                          foregroundColor: AppColors.primaryPurple,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.zero,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shopping_bag_rounded, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              "View ${links.length} Options", 
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}