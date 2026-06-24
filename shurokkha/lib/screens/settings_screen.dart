import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/language_provider.dart';
import '../services/pin_provider.dart';
import '../services/notification_provider.dart';
import '../services/app_strings.dart';
import '../services/localization_extension.dart';
import '../services/auth_provider.dart';
import '../services/theme_provider.dart';

import 'profile_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _navIndex = 3;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(AppThemeProvider provider) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) provider.updateBgImage(image.path);
  }

  void _showColorPicker(AppThemeProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Pick App Theme Color"),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: provider.primaryColor,
            onColorChanged: (color) => provider.updateColor(color),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Done"))],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              auth.logout();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<AppThemeProvider>();
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFF),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]),
                      child: const Icon(Icons.arrow_back, color: AppColors.textDark, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(context.translate('settings') ?? 'Settings', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // --- PERSONALIZATION SECTION ---
                    _buildSectionTitle("Personalization"),
                    
                    // App Color Selection
                    _buildSettingsCard(
                      icon: Icons.palette_outlined,
                      title: "App Theme Color",
                      subtitle: "Change primary app color",
                      iconColor: themeProvider.primaryColor,
                      trailing: CircleAvatar(radius: 12, backgroundColor: themeProvider.primaryColor),
                      onTap: () => _showColorPicker(themeProvider),
                    ),
                    const SizedBox(height: 16),

                    // Home Background Selection UI
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: _cardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.wallpaper_rounded, color: themeProvider.primaryColor, size: 26),
                              const SizedBox(width: 12),
                              const Text("Home Background", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: [
                                _buildBgOption(themeProvider, null, "Clear"), // Empty/Color
                                _buildBgOption(themeProvider, 'assets/bg1.png', "Pattern 1"), // Add this image to your assets
                                _buildBgOption(themeProvider, 'assets/bg2.png', "Pattern 2"), 
                                 _buildBgOption(themeProvider, 'assets/bg3.png', "Pattern 3"), // Add this image to your assets
                                 _buildBgOption(themeProvider, 'assets/bg4.png', "Pattern 2"), // Add this image to your assets

                                _buildUploadBgOption(themeProvider), // Upload Custom Button
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),

                    // --- ACCOUNT & PROFILE SECTION ---
                    _buildSectionTitle("Account Settings"),
                    _buildSettingsCard(
                      icon: Icons.person_outline,
                      title: context.translate('profile') ?? 'Profile',
                      subtitle: 'Manage your profile information',
                      iconColor: themeProvider.primaryColor,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileSettingsScreen())),
                    ),
                    const SizedBox(height: 12),

                    Consumer<LanguageProvider>(
                      builder: (context, languageProvider, _) {
                        return _buildSettingsCard(
                          icon: Icons.language,
                          title: AppStrings.get('change_language', languageProvider.locale.languageCode),
                          subtitle: languageProvider.isEnglish ? 'English' : 'বাংলা',
                          iconColor: themeProvider.primaryColor,
                          onTap: () => languageProvider.changeLanguage(languageProvider.isEnglish ? 'bn' : 'en'),
                        );
                      },
                    ),
                  

                    
                    const SizedBox(height: 24),

                    // --- APP SETTINGS SECTION ---
                    _buildSectionTitle("App Settings"),
                    Consumer<NotificationProvider>(
                      builder: (context, notificationProvider, _) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: _cardDecoration(),
                          child: Row(
                            children: [
                              Icon(Icons.notifications_outlined, size: 28, color: themeProvider.primaryColor),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(context.translate('notifications') ?? 'Notifications', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                    const Text('Tips & Messages', style: TextStyle(fontSize: 13, color: AppColors.textGrey)),
                                  ],
                                ),
                              ),
                              Switch(
                                value: notificationProvider.notificationsEnabled,
                                onChanged: (value) => notificationProvider.toggleNotifications(value),
                                activeColor: themeProvider.primaryColor,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsCard(
                      icon: Icons.security,
                      title: context.translate('privacy_policy') ?? 'Privacy Policy',
                      subtitle: 'Your data is safe',
                      iconColor: themeProvider.primaryColor,
                      onTap: () => Navigator.pushNamed(context, '/privacy-policy'),
                    ),
                    const SizedBox(height: 24),

                    // --- LOGOUT ---
                    _buildSettingsCard(
                      icon: Icons.logout_rounded,
                      title: "Logout",
                      subtitle: "Sign out of your account",
                      iconColor: Colors.redAccent,
                      titleColor: Colors.redAccent,
                      onTap: () => _showLogoutDialog(context, authProvider),
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // AppBottomNav(
            //   currentIndex: _navIndex,
            //   onTap: (i) {
            //     setState(() => _navIndex = i);
            //     if (i == 0) Navigator.pop(context);
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  // --- UI Helpers ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
    );
  }

  Widget _buildSettingsCard({
    required IconData icon, required String title, required String subtitle,
    required VoidCallback onTap, Widget? trailing, Color? iconColor, Color? titleColor,
  }) {
    return Container(
      decoration: _cardDecoration(),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: onTap,
        leading: Icon(icon, color: iconColor ?? AppColors.primaryPurple, size: 28),
        title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: titleColor ?? AppColors.textDark)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textGrey)),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textGrey),
      ),
    );
  }

  // Option for Default Images
  Widget _buildBgOption(AppThemeProvider provider, String? path, String label) {
    bool isSelected = provider.bgImagePath == path;
    return GestureDetector(
      onTap: () => provider.updateBgImage(path),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 65, height: 85,
              decoration: BoxDecoration(
                color: path == null ? provider.primaryColor.withOpacity(0.1) : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? provider.primaryColor : Colors.transparent, width: 3),
                image: path != null ? DecorationImage(image: AssetImage(path), fit: BoxFit.cover) : null,
              ),
              child: path == null ? const Icon(Icons.block, color: Colors.grey) : null,
            ),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? provider.primaryColor : Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  // Option to Upload User Image
  Widget _buildUploadBgOption(AppThemeProvider provider) {
    bool isUploadedFile = provider.bgImagePath != null && !provider.bgImagePath!.startsWith('assets/');
    return GestureDetector(
      onTap: () => _pickImage(provider),
      child: Column(
        children: [
          Container(
            width: 65, height: 85,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isUploadedFile ? provider.primaryColor : Colors.grey.shade300, width: isUploadedFile ? 3 : 1),
              image: isUploadedFile ? DecorationImage(image: FileImage(File(provider.bgImagePath!)), fit: BoxFit.cover) : null,
            ),
            child: !isUploadedFile ? Icon(Icons.add_a_photo_outlined, color: Colors.grey.shade500) : null,
          ),
          const SizedBox(height: 6),
          Text("Upload", style: TextStyle(fontSize: 12, fontWeight: isUploadedFile ? FontWeight.bold : FontWeight.normal, color: isUploadedFile ? provider.primaryColor : Colors.grey.shade600)),
        ],
      ),
    );
  }

  void _showChangePinDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change PIN"),
        content: const Text("Enter new PIN details here."),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
      ),
    );
  }
}