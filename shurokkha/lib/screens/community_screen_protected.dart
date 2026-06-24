import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/localization_extension.dart';
import '../services/auth_provider.dart';
import '../services/language_provider.dart';
import '../services/firebase_community_service.dart';
import 'home_screen.dart';
import 'period_tracker_screen.dart';
import 'chat_screen.dart';
import 'shop_screen.dart';

class CommunityScreenNew extends StatefulWidget {
  const CommunityScreenNew({super.key});

  @override
  State<CommunityScreenNew> createState() => _CommunityScreenNewState();
}

class _CommunityScreenNewState extends State<CommunityScreenNew> {
  late FirebaseCommunityChatService _chatService;
  final TextEditingController _messageController = TextEditingController();
  bool _initializationFailed = false;
  bool _isSendingMessage = false;

  @override
  void initState() {
    super.initState();
    _chatService = FirebaseCommunityChatService();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      final authProvider = context.read<AuthProvider>();
      if (!authProvider.isLoggedIn) {
        if (mounted) {
          _showLoginSignupDialog();
        }
      } else {
        await _chatService.initialize();
        if (mounted) {
          setState(() {
            _initializationFailed = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _initializationFailed = true;
        });
        _showErrorDialog('Initialization Error', 'Failed to initialize: $e');
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _initializeFirebase();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showLoginSignupDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Column(
          children: [
            const SizedBox(height: 12),
            const Text(
              '💜 আমাদের সম্প্রদায়ে স্বাগতম',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryPurple,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'এটি একটি নিরাপদ, গোপনীয় জায়গা যেখানে আপনি খোলামেলাভাবে কথা বলতে পারেন',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),

          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'পরে দেখব',
              style: TextStyle(color: AppColors.textGrey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showAuthOptions();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'লগইন / সাইনআপ',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showAuthOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'কীভাবে লগইন করবেন?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _authButton(
              icon: Icons.mail,
              label: 'ইমেইল দিয়ে লগইন করুন',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
            Text(
              'আপনার তথ্য সম্পূর্ণ গোপনীয় থাকবে 🔒',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _authButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color color = Colors.blue,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      title: Text(
        '💜 ${context.translate('community_title')}',
        style: const TextStyle(
          color: AppColors.primaryPurple,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      actions: [
        Consumer<LanguageProvider>(
          builder: (context, langProvider, _) {
            return PopupMenuButton<String>(
              onSelected: (value) async {
                await langProvider.changeLanguage(value);
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'bn',
                  child: Row(
                    children: [
                      Text(
                        langProvider.isBengali ? '✓' : ' ',
                        style: const TextStyle(
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('বাংলা'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'en',
                  child: Row(
                    children: [
                      Text(
                        langProvider.isEnglish ? '✓' : ' ',
                        style: const TextStyle(
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('English'),
                    ],
                  ),
                ),
              ],
              icon: const Icon(
                Icons.language,
                color: AppColors.primaryPurple,
              ),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
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
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (!authProvider.isLoggedIn) {
            return _buildLoginPrompt();
          }

          if (_initializationFailed) {
            return _buildErrorWidget();
          }

          return _buildCommunityChat(authProvider);
        },
      ),
    );
  }

  Widget _buildErrorWidget() {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            const Text(
              'সংযোগ সমস্যা',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'কমিউনিটি লোড করতে ব্যর্থ হয়েছে। আপনার ইন্টারনেট সংযোগ পরীক্ষা করুন।',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textGrey,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _initializationFailed = false;
                });
                _initializeFirebase();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('আবার চেষ্টা করুন'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '💜',
              style: TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 24),
            const Text(
              'সম্প্রদায়ে যোগ দিন',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'নিরাপদ, বিশ্বস্ত এবং গোপনীয়',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _showAuthOptions,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'এখনই যোগ দিন',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityChat(AuthProvider authProvider) {
    return GradientBackground(
      colors: const [
        Colors.white,
        Color(0xFFFAF5FF),
      ],
      child: Column(
        children: [
          // Safe space banner
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildSafeSpaceBanner(),
          ),

          // Chat messages
          Expanded(
            child: StreamBuilder<List<CommunityMessage>>(
              stream: _chatService.getMessagesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryPurple,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            '💬',
                            style: TextStyle(fontSize: 64),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          context.read<LanguageProvider>().isBengali
                              ? 'এখানে এখনও কোনো বার্তা নেই'
                              : 'No messages yet',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          context.read<LanguageProvider>().isBengali
                              ? 'প্রথম বার্তা পাঠান এবং কথোপকথন শুরু করুন!'
                              : 'Send the first message to start the conversation!',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageBubble(
                      messages[index],
                      authProvider,
                      context.read<LanguageProvider>(),
                    );
                  },
                );
              },
            ),
          ),

          // Message input area
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primaryPurple.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _messageController,
                      enabled: !_isSendingMessage,
                      decoration: InputDecoration(
                        hintText: context.read<LanguageProvider>().isBengali
                            ? 'আপনার বার্তা লিখুন...'
                            : 'Type your message...',
                        hintStyle: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      minLines: 1,
                      maxLength: 500,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: _isSendingMessage
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white),
                    onPressed: _isSendingMessage
                        ? null
                        : () async {
                            setState(() => _isSendingMessage = true);
                            await _sendMessage(context.read<AuthProvider>());
                            if (mounted) {
                              setState(() => _isSendingMessage = false);
                            }
                          },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafeSpaceBanner() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryPurple.withOpacity(0.08),
            AppColors.primaryPurple.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primaryPurple.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: AppColors.primaryPurple,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.translate('safe_space_title'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.primaryPurple,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  context.translate('safe_space_description'),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    CommunityMessage message,
    AuthProvider authProvider,
    LanguageProvider langProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Message header with user info
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryPurple,
                      AppColors.primaryPurple.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withOpacity(0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    (message.username.isNotEmpty ? message.username[0] : '👤')
                        .toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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
                        Expanded(
                          child: Text(
                            message.isAnonymous
                                ? langProvider.isBengali
                                    ? 'বেনামী ব্যবহারকারী'
                                    : 'Anonymous User'
                                : message.username,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppColors.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (message.isAnonymous)
                          const SizedBox(width: 6),
                        if (message.isAnonymous)
                          Tooltip(
                            message: langProvider.isBengali
                                ? 'এই বার্তা বেনামীভাবে পাঠানো হয়েছে'
                                : 'This message was sent anonymously',
                            child: const Icon(
                              Icons.privacy_tip_outlined,
                              size: 14,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatMessageTime(message.timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Message content
          Container(
            margin: const EdgeInsets.only(left: 52),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              message.message,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(AuthProvider authProvider) async {
    if (_messageController.text.trim().isEmpty) {
      _showSnackBar(
        context.read<LanguageProvider>().isBengali
            ? 'কিছু লিখুন দয়া করে'
            : 'Please write something',
        Colors.grey[600]!,
        Icons.info,
      );
      return;
    }

    try {
      final message = _messageController.text.trim();
      _messageController.clear();
      
      // Hide keyboard
      FocusScope.of(context).unfocus();

      await _chatService.sendMessage(
        userId: authProvider.phoneNumber ?? authProvider.userEmail ?? 'unknown',
        username: authProvider.userName ?? 'ব্যবহারকারী',
        message: message,
        isAnonymous: true,
      );

      _showSnackBar(
        context.read<LanguageProvider>().isBengali
            ? 'বার্তা পাঠানো হয়েছে ✓'
            : 'Message sent ✓',
        Colors.green[600]!,
        Icons.check_circle,
        duration: const Duration(milliseconds: 1000),
      );
    } catch (e) {
      _showSnackBar(
        'Error: $e',
        Colors.red[600]!,
        Icons.error,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _showSnackBar(
    String message,
    Color backgroundColor,
    IconData icon, {
    Duration duration = const Duration(milliseconds: 2000),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return context.read<LanguageProvider>().isBengali
          ? 'এখনই'
          : 'Just now';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return context.read<LanguageProvider>().isBengali
          ? '${mins}মিনিট আগে'
          : '${mins}m ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return context.read<LanguageProvider>().isBengali
          ? '${hours}ঘণ্টা আগে'
          : '${hours}h ago';
    } else {
      return context.read<LanguageProvider>().isBengali
          ? dateTime.toLocal().toString().split(' ')[0]
          : dateTime.toLocal().toString().split(' ')[0];
    }
  }
}
