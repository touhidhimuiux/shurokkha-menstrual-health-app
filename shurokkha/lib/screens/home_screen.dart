import 'dart:io';
import 'dart:convert';
import 'dart:ui'; // Required for premium glassmorphic blur layers
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'profile_settings_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/period_reminder_card.dart';

import '../services/period_data_provider.dart';
import '../services/auth_provider.dart';
import '../services/firestore_user_service.dart';
import '../services/localization_extension.dart';
import '../services/theme_provider.dart';

import 'period_tracker_screen.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';
import 'community_feed_screen.dart';
import 'period_products_guide_screen.dart';
import 'health_tips_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({
    super.key,
    this.userName = 'User',
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadUserData();
        context.read<PeriodDataProvider>().refreshData();
      }
    });
  }

  Future<void> _loadUserData() async {
    try {
      final firestoreService = FirestoreUserService();
      await firestoreService.fetchUserData();
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  // Helper to load either Asset (default) or File (uploaded) image
  ImageProvider _getBackgroundImage(String path) {
    if (path.startsWith('assets/')) {
      return AssetImage(path);
    } else {
      return FileImage(File(path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<AppThemeProvider>();

    return Scaffold(
      backgroundColor: themeProvider.bgImagePath == null ? const Color(0xFFFBFBFF) : Colors.transparent,
      
      // --- HEADER SECTION ---
      appBar: AppBar(
        elevation: 1, 
        shadowColor: Colors.black.withOpacity(0.08),
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white, 
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        title: Row(
          children: [
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileSettingsScreen()),
                );
                if (result == true) setState(() {});
              },
              child: Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  ImageProvider? profileImage;
                  if (auth.profileImageUrl != null && auth.profileImageUrl!.isNotEmpty) {
                    if (auth.profileImageUrl!.startsWith('http')) {
                      profileImage = NetworkImage(auth.profileImageUrl!);
                    } else {
                      try {
                        profileImage = MemoryImage(base64Decode(auth.profileImageUrl!));
                      } catch (e) {
                        debugPrint('Error decoding base64: $e');
                      }
                    }
                  }
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: themeProvider.primaryColor, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.grey.shade100,
                      backgroundImage: profileImage,
                      child: (profileImage == null)
                          ? Icon(Icons.person, color: themeProvider.primaryColor)
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hello, ${authProvider.userName ?? 'User'} 👋',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
                  ),
                  Text(
                    'Stay healthy & tracked',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: themeProvider.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.settings_outlined, color: themeProvider.primaryColor, size: 24),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (i) {
          if (i == 0) return;
          _handleNavigation(i);
        },
      ),
      // --- BODY SECTION ---
      body: Container(
        decoration: BoxDecoration(
          image: themeProvider.bgImagePath != null
              ? DecorationImage(
                  image: _getBackgroundImage(themeProvider.bgImagePath!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: PeriodReminderCard(),
                ),
                const SizedBox(height: 32),
                
                // Quick Actions Title Section with Balanced Contrast
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    context.translate('quick_actions') ?? 'Quick Actions',
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.w900, 
                      color: themeProvider.bgImagePath != null ? Colors.white : const Color(0xFF331652),
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Optimized, High-Vibrancy Actions Grid Matrix
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.85, 
                    children: [
                      _buildQuickActionCard(
                        title: 'Period\nTracking',
                        icon: Icons.calendar_month_rounded,
                        gradientColors: [const Color(0xFFFF3366), const Color(0xFFFF6B8B)], // Radiant Pink
                        onTap: () => _handleNavigation(1),
                      ),
                      _buildQuickActionCard(
                        title: 'Chat\nwith AI',
                        icon: Icons.chat_bubble_rounded,
                        gradientColors: [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)], // Deep Vivid Neon Purple
                        onTap: () => _handleNavigation(2),
                      ),
                      _buildQuickActionCard(
                        title: 'Shop',
                        icon: Icons.shopping_bag_rounded,
                        gradientColors: [const Color(0xFF00C6FF), const Color(0xFF0072FF)], // Radiant Electric Cyan-Blue
                        onTap: () => _handleNavigation(3),
                      ),
                      _buildQuickActionCard(
                        title: 'Community',
                        icon: Icons.people_alt_rounded,
                        gradientColors: [const Color(0xFF11998E), const Color(0xFF38EF7D)], // Saturated Mint Green
                        onTap: () => _handleNavigation(4),
                      ),
                      _buildQuickActionCard(
                        title: 'Health\nTips',
                        icon: Icons.lightbulb_rounded,
                        gradientColors: [const Color(0xFFFF007F), const Color(0xFF9B00FF)], // Vibrant Ultraviolet Magenta
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthTipsScreen())),
                      ),
                      _buildQuickActionCard(
                        title: 'Products\nGuide',
                        icon: Icons.assignment_rounded,
                        gradientColors: [const Color(0xFFF12711), const Color(0xFFF5AF19)], // Luminous Sunset Orange Flare
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PeriodProductsGuideScreen())),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNavigation(int index) {
    Widget screen;
    switch (index) {
      case 1: screen = const PeriodTrackerScreen(); break;
      case 2: screen = const ChatScreen(); break;
      case 3: screen = const ShopScreen(); break;
      case 4: screen = const CommunityFeedScreen(); break;
      default: return;
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => screen));
  }

  // Premium, High-Contrast Glassmorphic Card Generation Engine 
  Widget _buildQuickActionCard({
    required String title,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white.withOpacity(0.35), 
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Circular White Translucent Icon Frame Container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 1.2,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.white, // Inverted safely for clarity over bright colors
                    height: 1.2,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}