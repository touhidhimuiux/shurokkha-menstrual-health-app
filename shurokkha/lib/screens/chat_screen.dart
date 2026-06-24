import 'dart:convert';
import 'dart:ui'; // Required for trending Glassmorphic effects
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:shurokkha/cubits/search_cubit.dart';
import 'package:shurokkha/cubits/search_state.dart';
import 'package:shurokkha/models/message.dart';

import '../services/auth_provider.dart';
import 'home_screen.dart';
import 'period_tracker_screen.dart';
import 'shop_screen.dart';
import 'community_feed_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final int _currentNavIndex = 2; // Chat tab

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleNavigation(int index) {
    if (index == _currentNavIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PeriodTrackerScreen()));
        break;
      case 2:
        break; 
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ShopScreen()));
        break;
      case 4:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CommunityFeedScreen()));
        break;
    }
  }

  // Live Firebase database handler for background synchronization
  Future<void> _updateChatBackgroundSettings(String type, String value) async {
    if (currentUser == null) return;
    await _firestore.collection('users').doc(currentUser!.uid).update({
      'home_background_type': type,
      'home_background_value': value,
    });
  }

  // Dynamic image renderer supporting standard URLs, Base64 strings, or local assets
  Widget _buildLiveAvatar(String? avatarData, String? backupName, {double radius = 16}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFF7B35B5).withOpacity(0.1),
        backgroundImage: (avatarData != null && avatarData.isNotEmpty)
            ? (avatarData.startsWith('http')
                ? NetworkImage(avatarData)
                : MemoryImage(base64Decode(avatarData)) as ImageProvider)
            : null,
        child: (avatarData == null || avatarData.isEmpty)
            ? Text(
                backupName != null && backupName.isNotEmpty ? backupName[0].toUpperCase() : 'U',
                style: TextStyle(color: const Color(0xFF7B35B5), fontSize: radius * 0.8, fontWeight: FontWeight.bold),
              )
            : null,
      ),
    );
  }

  // Method placeholder for custom photo gallery image pickers
  Future<void> _pickImageFromLocalGallery() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gallery Picker clicked! Integrate image_picker package path here.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return StreamBuilder<DocumentSnapshot>(
      stream: currentUser != null
          ? _firestore.collection('users').doc(currentUser!.uid).snapshots()
          : const Stream.empty(),
      builder: (context, userSnapshot) {
        // --- REALTIME DEFAULTS ---
        String currentUserName = currentUser?.displayName ?? 'User';
        String currentUserAvatar = currentUser?.photoURL ?? '';
        String chatBackgroundType = "gradient";
        String chatBackgroundValue = "";

        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          var userData = userSnapshot.data!.data() as Map<String, dynamic>;
          currentUserName = userData['name'] ?? currentUserName;
          currentUserAvatar = userData['profileImageUrl'] ?? currentUserAvatar;
          chatBackgroundType = userData['home_background_type'] ?? "gradient";
          chatBackgroundValue = userData['home_background_value'] ?? "";
        }

        // Realtime Balance Contrast Handler for content outside white containers
        bool useDarkTextTheme = true;
        if (chatBackgroundType == "gradient" && 
            (chatBackgroundValue == "midnight_royal" || chatBackgroundValue == "berry_velvet" || chatBackgroundValue == "emerald_breeze")) {
          useDarkTextTheme = false;
        }

        return Scaffold(
          extendBodyBehindAppBar: false, // Isolated navbar boundaries cleanly
          appBar: AppBar(
            backgroundColor: Colors.white, // Locked background to solid white for clear readability
            elevation: 1, 
            shadowColor: Colors.black.withOpacity(0.1),
            surfaceTintColor: Colors.white,
            leading: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
              },
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF7B35B5).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF7B35B5),
                  size: 20,
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Dr. Sia - Health AI',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF7B35B5), // Explicit fixed readable branding text color
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Always here for you 💜',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
              ],
            ),
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.auto_fix_high, color: Color(0xFF7B35B5)), // High contrast customizer icon
                onPressed: () => _displayBackgroundCustomizerSheet(context),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Stack(
            children: [
              // 1. Dynamic Background Renderer Layer
              _renderDynamicThemeBackground(chatBackgroundType, chatBackgroundValue),

              // 2. Main Chat Conversation Layer
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: BlocBuilder<SearchCubit, SearchState>(
                        builder: (context, state) {
                          List<Message> messages = [];
                          bool isLoading = false;

                          if (state is SearchChatState) {
                            messages = state.messages;
                            isLoading = state.isLoading;
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scrollToBottom();
                            });
                          }

                          return messages.isEmpty
                              ? Center(
                                  child: SingleChildScrollView(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                        child: Container(
                                          padding: const EdgeInsets.all(24),
                                          margin: const EdgeInsets.symmetric(horizontal: 24),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.4),
                                            borderRadius: BorderRadius.circular(24),
                                            border: Border.all(color: Colors.white.withOpacity(0.5)),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 80,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: const Color(0xFF7B35B5).withOpacity(0.2),
                                                      blurRadius: 12,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                                child: ClipOval(
                                                  child: Image.asset(
                                                    'assets/chatbot_profile.png',
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              Text(
                                                'Welcome, $currentUserName!',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFF1A1A1A),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              const Text(
                                                'Your Personal Health Companion',
                                                style: TextStyle(
                                                  fontSize: 14, 
                                                  color: Color(0xFF4A4A4A), 
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              const Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 16),
                                                child: Text(
                                                  'Ask me anything about your health, period cycle, nutrition, or wellness. I\'m here to help! ✨',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Color(0xFF2D2D2D),
                                                    height: 1.5,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.all(16),
                                  itemCount: messages.length + (isLoading ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == messages.length && isLoading) {
                                      return _buildTypingIndicator(useDarkTextTheme);
                                    }
                                    final msg = messages[index];
                                    return _buildMessageBubble(msg, currentUserName, currentUserAvatar, useDarkTextTheme);
                                  },
                                );
                        },
                      ),
                    ),

                    // Sub Query Action Prompt Chips View Area
                    BlocBuilder<SearchCubit, SearchState>(
                      builder: (context, state) {
                        bool showChips = true;
                        if (state is SearchChatState && state.messages.isNotEmpty) {
                          showChips = false;
                        }
                        if (!showChips) return const SizedBox.shrink();

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              _buildQuickActionChip('Period Info', Icons.water_drop_outlined, context),
                              const SizedBox(width: 8),
                              _buildQuickActionChip('Pain Relief', Icons.healing_outlined, context),
                              const SizedBox(width: 8),
                              _buildQuickActionChip('Nutrition', Icons.restaurant_menu_outlined, context),
                              const SizedBox(width: 8),
                              _buildQuickActionChip('Mood', Icons.mood_outlined, context),
                              const SizedBox(width: 8),
                              _buildQuickActionChip('Products', Icons.shopping_bag_outlined, context),
                            ],
                          ),
                        );
                      },
                    ),

                    // Glassmorphic Input Field Panel
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: Colors.white.withOpacity(0.8)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: TextField(
                                      controller: _messageController,
                                      style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 15, fontWeight: FontWeight.w600),
                                      decoration: InputDecoration(
                                        hintText: 'Ask me anything...',
                                        hintStyle: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w400),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                        border: InputBorder.none,
                                      ),
                                      maxLines: null,
                                      textInputAction: TextInputAction.send,
                                      onSubmitted: (_) {
                                        if (_messageController.text.trim().isNotEmpty) {
                                          context.read<SearchCubit>().getSearchResponse(
                                                query: _messageController.text.trim(),
                                              );
                                          _messageController.clear();
                                          setState(() {});
                                          _scrollToBottom();
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF7B35B5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                                    onPressed: () {
                                      if (_messageController.text.trim().isNotEmpty) {
                                        context.read<SearchCubit>().getSearchResponse(
                                              query: _messageController.text.trim(),
                                            );
                                        _messageController.clear();
                                        setState(() {});
                                        _scrollToBottom();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentNavIndex,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF7B35B5),
            unselectedItemColor: Colors.grey.shade500,
            backgroundColor: Colors.white,
            onTap: _handleNavigation,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Tracker'),
              BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Chat'),
              BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Shop'),
              BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Community'),
            ],
          ),
        );
      },
    );
  }

  // Classical Multi-Variety Dynamic Background Switcher Engine (Supports Assets & Gradients)
  Widget _renderDynamicThemeBackground(String type, String value) {
    if (type == "image" && value.isNotEmpty) {
      if (value.startsWith('assets/')) {
        return Positioned.fill(
          child: Image.asset(value, fit: BoxFit.cover),
        );
      }
      return Positioned.fill(
        child: Image.network(
          value,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: const Color(0xFFE6E6FA),
          ),
        ),
      );
    } else if (type == "color" && value.isNotEmpty) {
      return Positioned.fill(
        child: Container(
          color: Color(int.parse(value.replaceAll('#', '0xff'))),
        ),
      );
    }
    
    // Gradients Varieties Combinations Mapping
    List<Color> targetColors = [const Color(0xFFFFE0E9), const Color(0xFFE6E6FA), Colors.white];
    if (value == "sunset_glow") targetColors = [const Color(0xFFFF5F6D), const Color(0xFFFFC371)];
    if (value == "ocean_depth") targetColors = [const Color(0xFF2193b0), const Color(0xFF6dd5ed)];
    if (value == "teal_lux") targetColors = [const Color(0xFF11998e), const Color(0xFF38ef7d)];
    if (value == "emerald_breeze") targetColors = [const Color(0xFF0ba360), const Color(0xFF3cba92)];
    if (value == "midnight_royal") targetColors = [const Color(0xFF0f2027), const Color(0xFF203a43), const Color(0xFF2c5364)];
    if (value == "berry_velvet") targetColors = [const Color(0xFF4e54c8), const Color(0xFF8f94fb)];

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: targetColors,
          ),
        ),
      ),
    );
  }

  // Expanded Classical Customization Drawer BottomSheet Layout
  void _displayBackgroundCustomizerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        maxChildSize: 0.85,
        builder: (_, scrollController) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(color: Colors.white.withOpacity(0.4)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),        
                      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const Center(
                    child: Text(
                      "Classical Chat Customizer",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildCategoryHeader("Classical Gradients Combinations"),
                  _buildHorizontalScrollWrapper([
                    _buildGradientOptionItem("Default", [const Color(0xFFFFE0E9), const Color(0xFFE6E6FA)], () => _updateChatBackgroundSettings("gradient", "")),
                    _buildGradientOptionItem("Sunset Glow", [const Color(0xFFFF5F6D), const Color(0xFFFFC371)], () => _updateChatBackgroundSettings("gradient", "sunset_glow")),
                    _buildGradientOptionItem("Ocean Depth", [const Color(0xFF2193b0), const Color(0xFF6dd5ed)], () => _updateChatBackgroundSettings("gradient", "ocean_depth")),
                    _buildGradientOptionItem("Teal Lux", [const Color(0xFF11998e), const Color(0xFF38ef7d)], () => _updateChatBackgroundSettings("gradient", "teal_lux")),
                    _buildGradientOptionItem("Emerald", [const Color(0xFF0ba360), const Color(0xFF3cba92)], () => _updateChatBackgroundSettings("gradient", "emerald_breeze")),
                    _buildGradientOptionItem("Midnight", [const Color(0xFF0f2027), const Color(0xFF2c5364)], () => _updateChatBackgroundSettings("gradient", "midnight_royal")),
                    _buildGradientOptionItem("Berry Velvet", [const Color(0xFF4e54c8), const Color(0xFF8f94fb)], () => _updateChatBackgroundSettings("gradient", "berry_velvet")),
                  ]),

                  _buildCategoryHeader("Classical Solids Varieties"),
                  _buildHorizontalScrollWrapper([
                    _buildSolidOptionItem("Teal Clean", "#E0F2F1", () => _updateChatBackgroundSettings("color", "#E0F2F1")),
                    _buildSolidOptionItem("Soft Rose", "#FCE4EC", () => _updateChatBackgroundSettings("color", "#FCE4EC")),
                    _buildSolidOptionItem("Lavender", "#F3E5F5", () => _updateChatBackgroundSettings("color", "#F3E5F5")),
                    _buildSolidOptionItem("Sky Soft", "#E1F5FE", () => _updateChatBackgroundSettings("color", "#E1F5FE")),
                    _buildSolidOptionItem("Mint Pastel", "#E8F5E9", () => _updateChatBackgroundSettings("color", "#E8F5E9")),
                    _buildSolidOptionItem("Warm Almond", "#FFF3E0", () => _updateChatBackgroundSettings("color", "#FFF3E0")),
                  ]),

                  _buildCategoryHeader("Default Art Gallery (Local Assets)"),
                  _buildHorizontalScrollWrapper([
                    _buildArtOptionItem("assets/c10.png", " "),
                    _buildArtOptionItem("assets/c2.png", " "),
                    _buildArtOptionItem("assets/c3.png", " "),
                    _buildArtOptionItem("assets/c4.png", " "),
                    _buildArtOptionItem("assets/c5.png", " "),
                    _buildArtOptionItem("assets/c6.png", " "),
                    _buildArtOptionItem("assets/c7.png", " "),
                    _buildArtOptionItem("assets/c8.png", " "),
                    _buildArtOptionItem("assets/c9.png", " "),
                    _buildArtOptionItem("assets/c1.png", " "),
                    
                  ]),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black54, letterSpacing: 0.3),
      ),
    );
  }

  Widget _buildHorizontalScrollWrapper(List<Widget> children) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: children.map((w) => Padding(padding: const EdgeInsets.only(right: 12), child: w)).toList(),
      ),
    );
  }

  Widget _buildGradientOptionItem(String label, List<Color> colors, VoidCallback action) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        action();
      },
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2))],
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
        ],
      ),
    );
  }

  Widget _buildSolidOptionItem(String label, String hexCode, VoidCallback action) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        action();
      },
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(int.parse(hexCode.replaceAll('#', '0xff'))),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2))],
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
        ],
      ),
    );
  }

  Widget _buildArtOptionItem(String assetPath, String label) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _updateChatBackgroundSettings("image", assetPath);
      },
      child: Column(
        children: [
          Container(
            width: 85,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(image: AssetImage(assetPath), fit: BoxFit.cover),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2))],
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
        ],
      ),
    );
  }

  // --- TRENDING GLASSMORPHISM CHAT BUBBLES WITH REAL-TIME PROFILE RENDERING ---
  Widget _buildMessageBubble(Message message, String name, String avatar, bool useDarkTextTheme) {
    bool isUser = message.isUser;
    Color systemTextColor = useDarkTextTheme ? const Color(0xFF1A1A1A) : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset('assets/chatbot_profile.png', fit: BoxFit.cover),
                ),
              ),
            ),

          Flexible(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isUser ? 20 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 20),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser 
                        ? const Color(0xFF7B35B5).withOpacity(0.85) 
                        : Colors.white.withOpacity(0.55),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                    border: Border.all(
                      color: isUser ? Colors.white.withOpacity(0.25) : Colors.white.withOpacity(0.6)
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : const Color(0xFF1A1A1A), // Locked incoming text to clear dark charcoal inside the bubble
                      fontSize: 15,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (isUser)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _buildLiveAvatar(avatar, name, radius: 16),
            ),
        ],
      ),
    );
  }

  // Pure Opaque White Sub-Query Prompt Chips 
  Widget _buildQuickActionChip(String label, IconData icon, BuildContext context) {
    return GestureDetector(
      onTap: () {
        String query = label;
        if (label == 'Period Info') query = 'Tell me about menstrual cycle and period care';
        else if (label == 'Pain Relief') query = 'What are the best ways to relieve period pain?';
        else if (label == 'Nutrition') query = 'What nutrition is important during my cycle?';
        else if (label == 'Mood') query = 'How to manage mood changes during my period?';
        else if (label == 'Products') query = 'What period products are available and safe to use?';

        context.read<SearchCubit>().getSearchResponse(query: query);
        _scrollToBottom();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white, // Locked background to solid white for visibility 
          border: Border.all(
            color: const Color(0xFF7B35B5), // Enhanced purple accent border line
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ]
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF7B35B5)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF7B35B5),
                fontWeight: FontWeight.w700, // Thick bold font weight configurations
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- DYNAMIC THINKING & WRITING ANIMATION ENGINE ---
  Widget _buildTypingIndicator(bool useDarkTextTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: ClipOval(child: Image.asset('assets/chatbot_profile.png', fit: BoxFit.cover)),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 6),
                child: Row(
                  children: [
                    // Moving/Rotating Thinking Mind Icon Configuration
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 360.0),
                      duration: const Duration(seconds: 2),
                      builder: (context, rotationValue, child) {
                        return Transform.rotate(
                          angle: rotationValue * (3.141592653589793 / 180),
                          
                        );
                      },
                      onEnd: () => setState(() {}), // Infinite continuous looping structure
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Dr. Sia is thinking...",
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: useDarkTextTheme ? Colors.white : const Color.fromARGB(179, 255, 255, 255),
                        fontWeight: FontWeight.w700
                      ),
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(20),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(20),
                      ),
                      border: Border.all(color: Colors.white.withOpacity(0.6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildDot(0), const SizedBox(width: 4),
                        _buildDot(1), const SizedBox(width: 4),
                        _buildDot(2),
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

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 100)),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -4 * (value > 0.5 ? 1 - value : value)),
          child: Opacity(
            opacity: value,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7B35B5).withOpacity(0.6),
              ),
            ),
          ),
        );
      },
      onEnd: () => setState(() {}),
    );
  }
}