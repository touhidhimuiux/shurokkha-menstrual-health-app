import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'pin_screen.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  int _selected = 0;

  final _languages = [
    {'icon': '📖', 'name': 'বাংলা', 'available': true},
    {'icon': 'Aa', 'name': 'Banglish', 'available': true},
    {'icon': '🧕', 'name': 'Local Dialect', 'available': false},
    {'icon': '👩', 'name': 'Local Dialect', 'available': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        colors: const [Color(0xFFEDD9FF), Color(0xFFE8D5FF), Color(0xFFD4C0F0), Color(0xFFC8B0E8)],
        child: SafeArea(
          child: Column(
            children: [
              // Back button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back_ios, size: 16,
                          color: AppColors.primaryPurple),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        'Choose Your Language',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Save Locally to Device',
                        style: TextStyle(fontSize: 14, color: AppColors.textGrey),
                      ),
                      const SizedBox(height: 30),

                      // Language options
                      ...List.generate(_languages.length, (i) {
                        final lang = _languages[i];
                        final isAvailable = lang['available'] as bool;
                        final isSelected = _selected == i;
                        return GestureDetector(
                          onTap: isAvailable ? () => setState(() => _selected = i) : null,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFFF8E1)
                                  : Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.mediumPink
                                    : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purple.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Icon
                                Container(
                                  width: 44, height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.softLavender,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: lang['icon'] == 'Aa'
                                        ? Text('Aa',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primaryPurple))
                                        : Text(lang['icon'] as String,
                                            style: const TextStyle(fontSize: 24)),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Name
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (!isAvailable)
                                        Text('Coming Soon',
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: AppColors.textGrey)),
                                      Text(
                                        lang['name'] as String,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: isAvailable
                                              ? AppColors.textDark
                                              : AppColors.textGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Check/arrow
                                isSelected
                                    ? Container(
                                        width: 30, height: 30,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.mediumPink,
                                        ),
                                        child: const Icon(Icons.check,
                                            color: Colors.white, size: 18),
                                      )
                                    : Icon(Icons.chevron_right,
                                        color: isAvailable
                                            ? AppColors.textGrey
                                            : AppColors.textGrey.withOpacity(0.4)),
                              ],
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 10),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'You can change this later in ',
                              style: TextStyle(fontSize: 13, color: AppColors.textGrey),
                            ),
                            TextSpan(
                              text: 'Settings',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textGrey),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      PurpleButton(
                        label: 'Continue',
                        icon: Icons.arrow_forward,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PinScreen()),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const PrivacyFooter(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}