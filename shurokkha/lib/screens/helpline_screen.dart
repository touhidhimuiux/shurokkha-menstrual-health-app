import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/localization_extension.dart';
import 'home_screen.dart';
import 'period_tracker_screen.dart';
import 'shop_screen.dart';
import 'community_screen_protected.dart';

class HelplineScreen extends StatefulWidget {
  const HelplineScreen({super.key});

  @override
  State<HelplineScreen> createState() => _HelplineScreenState();
}

class _HelplineScreenState extends State<HelplineScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'সব',
    'জরুরি',
    'মানসিক স্বাস্থ্য',
    'মহিলা স্বাস্থ্য'
  ];

  final List<Map<String, dynamic>> _helplines = [
    {
      'name': 'জাতীয় জরুরি সেবা',
      'description': 'জরুরি চিকিৎসা এবং গুরুতর পরিস্থিতির জন্য',
      'phone': '999',
      'category': 'জরুরি',
      'isEmergency': true,
      'isVerified': true,
      'available': '২৪/৭ উপলব্ধ',
      'color': Colors.red,
      'icon': Icons.emergency,
      'type': 'জরুরি সেবা',
    },

    // Mental Health Support
    {
      'name': 'মাইন্ডস্পেস',
      'description':
          'মানসিক স্বাস্থ্য সহায়তা এবং পরামর্শ সেবা (বিনামূল্যে ও গোপনীয়)',
      'phone': '09678-678-778',
      'category': 'মানসিক স্বাস্থ্য',
      'isEmergency': false,
      'isVerified': true,
      'available': '২৪/৭ উপলব্ধ',
      'color': Color(0xFF6C4FBB),
      'icon': Icons.psychology,
      'type': 'মানসিক সুস্থতা সহায়তা',
    },
    {
      'name': 'ব্র্যাক মনের জতনো',
      'description': 'ব্র্যাক দ্বারা মানসিক স্বাস্থ্য সহায়তা লাইন (বিনামূল্যে ও গোপনীয়)',
      'phone': '09643-262626',
      'category': 'মানসিক স্বাস্থ্য',
      'isEmergency': false,
      'isVerified': true,
      'available': '२४/७ উপলব্ধ',
      'color': Color(0xFF7C3AED),
      'icon': Icons.psychology,
      'type': 'মানসিক স্বাস্থ্য সহায়তা',
    },
    {
      'name': 'মনোশিক কস্টো',
      'description': 'মানসিক স্বাস্থ্য সংকট সহায়তা এবং পরামর্শ',
      'phone': '01766-406806',
      'category': 'মানসিক স্বাস্থ্য',
      'isEmergency': false,
      'isVerified': true,
      'available': 'সোম-রবি ৯AM-৯PM',
      'color': Color(0xFF8B5CF6),
      'icon': Icons.psychology,
      'type': 'মানসিক স্বাস্থ্য সংকট সহায়তা',
    },
    {
      'name': 'কান পেটে রই',
      'description': 'মানসিক স্বাস্থ্য সহায়তা হটলাইন',
      'phone': '09612-119911',
      'category': 'মানসিক স্বাস্থ্য',
      'isEmergency': false,
      'isVerified': true,
      'available': '२४/७ উপলব্ধ',
      'color': Color(0xFF6C4FBB),
      'icon': Icons.psychology,
      'type': 'শ্রবণ ও সহায়তা',
    },

    // Women Health/Reproductive Health
    {
      'name': 'মেরি স্টপস বাংলাদেশ',
      'description':
          'যৌন ও প্রজনন স্বাস্থ্য (SRH) সেবা এবং পরামর্শ',
      'phone': '08000-222-333',
      'category': 'মহিলা স্বাস্থ্য',
      'isEmergency': false,
      'isVerified': true,
      'available': '२४/७ উपलब्ध',
      'color': Color(0xFFE85B7D),
      'icon': Icons.favorite,
      'type': 'প্রজনন স্বাস্থ্য সেবা',
    },
    {
      'name': 'আরএইচএসটিইপি ঢাকা',
      'description':
          'প্রজনন স্বাস্থ্য সহায়তা এবং বিশেষজ্ঞ নির্দেশনা (পিরিয়ড, উর্বরতা, সুস্থতা)',
      'phone': '09611-775566',
      'category': 'মহিলা স্বাস্থ্য',
      'isEmergency': false,
      'isVerified': true,
      'available': 'দৈনিক ১০AM-६PM',
      'color': Color(0xFFE8A5C1),
      'icon': Icons.local_hospital,
      'type': 'প্রজনন স্বাস্থ্য ক্লিনিক',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredHelplines = _selectedCategory == 'All'
        ? _helplines
        : _helplines.where((h) => h['category'] == _selectedCategory).toList();

    return Scaffold(
      bottomNavigationBar: AppBottomNav(
        currentIndex: 2,
        onTap: (i) {
          if (i == 2) return;

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
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ShopScreen()),
              );
              break;
            case 4:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const CommunityScreenNew()),
              );
              break;
          }
        },
      ),
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
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.translate('helpline'),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outlined,
                          color: AppColors.textDark),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            title: const Text('About These Helplines'),
                            content: const SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'All helplines are staffed with trained professionals who maintain your privacy and confidentiality.',
                                    style: TextStyle(height: 1.5),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    '⚠️ Disclaimer',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Numbers and availability may change. Contact the health provider directly if needed.',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textGrey),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Info Banner
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.softLavender.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryPurple.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        color: AppColors.primaryPurple,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '১০০% গোপনীয় • বিনামূল্যে সহায়তা • প্রশিক্ষিত পেশাদার',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Category Filter Tabs
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: _categories.map((category) {
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedCategory = category);
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
                              category,
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

              // Helplines List
              Expanded(
                child: filteredHelplines.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.phone_in_talk_outlined,
                                size: 48, color: AppColors.textGrey),
                            const SizedBox(height: 12),
                            Text(
                              '"$_selectedCategory" তে কোন হেল্পলাইন নেই',
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
                        itemCount: filteredHelplines.length,
                        itemBuilder: (context, index) {
                          return _HelplineCard(
                              helpline: filteredHelplines[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelplineCard extends StatelessWidget {
  final Map<String, dynamic> helpline;

  const _HelplineCard({required this.helpline});

  /// Format Bangladesh phone numbers for tel: URI
  /// Converts: 09678-678-778 → +8809678678778
  /// Keeps:    999 → 999 (emergency)
  String _formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters except emergency '999'
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Keep emergency number as-is
    if (cleaned == '999') {
      return '999';
    }

    // If starts with 0 (Bangladesh local format), replace with country code 880
    if (cleaned.startsWith('0')) {
      return '+88${cleaned.substring(1)}';
    }

    // If already international format (880...), add +
    if (cleaned.startsWith('880')) {
      return '+$cleaned';
    }

    return '+88$cleaned';
  }

  Future<void> _makeCall(BuildContext context) async {
    final phoneNumber = helpline['phone'];
    final formattedNumber = _formatPhoneNumber(phoneNumber);
    final Uri uri = Uri(scheme: 'tel', path: formattedNumber);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Calling $phoneNumber...'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error calling $phoneNumber: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEmergency = helpline['isEmergency'] ?? false;

    // Emergency Card - Special treatment for 999
    if (isEmergency) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade600, Colors.red.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Emergency Helpline',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          helpline['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                helpline['description'],
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Call Now',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          helpline['phone'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _makeCall(context),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.phone,
                        color: Colors.red,
                        size: 28,
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

    // Regular Helpline Card
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
            // Header with Icon and Verified Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: helpline['color'].withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      helpline['icon'],
                      color: helpline['color'],
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              helpline['name'],
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          if (helpline['isVerified'] ?? false)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF007AFF)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF007AFF),
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Verified',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF007AFF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: helpline['color'].withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          helpline['type'],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: helpline['color'],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              helpline['description'],
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textGrey,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            // Availability
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  helpline['available'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Phone Number and Call Button
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Phone',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        helpline['phone'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: helpline['color'],
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _makeCall(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: helpline['color'],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.phone,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Call',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
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
}
