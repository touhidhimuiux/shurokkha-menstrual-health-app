import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        colors: const [Color(0xFFEDD9FF), Color(0xFFF0E0FF), Color(0xFFFFE6F5), Color(0xFFE8D5FF)],
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: AppColors.textDark, size: 28),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    const Icon(Icons.shield, color: AppColors.primaryPurple, size: 28),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _policySection(
                        icon: Icons.lock_outline,
                        title: 'Your Data is Safe',
                        content:
                            'All your personal health data, period tracking information, and medical history are stored securely on your device. We use industry-standard encryption to protect your sensitive information.',
                      ),
                      _policySection(
                        icon: Icons.people_alt,
                        title: 'We Never Share Your Data',
                        content:
                            'Your data is yours alone. We do not share, sell, or distribute your personal information to any third party, government agency, or external organization. Your privacy is our top priority.',
                      ),
                      _policySection(
                        icon: Icons.smartphone,
                        title: 'Local Storage Only',
                        content:
                            'Shurokkha stores all your data locally on your device. No information is uploaded to any cloud servers or external databases. You have complete control over your data at all times.',
                      ),
                      _policySection(
                        icon: Icons.security,
                        title: 'Security First',
                        content:
                            'We implement strong security measures including PIN protection, data encryption, and secure local storage. Your account is protected with a 4-digit PIN that only you know.',
                      ),
                      _policySection(
                        icon: Icons.person,
                        title: 'Your Privacy Matters',
                        content:
                            'We understand that period tracking is a personal matter. Your health information is confidential and will never be shared without your explicit consent.',
                      ),
                      _policySection(
                        icon: Icons.settings,
                        title: 'What Data We Collect',
                        content:
                            'We collect only the data you provide: period dates, symptoms, moods, and health notes. No browsing history, location data, or contact information is collected.',
                      ),
                      _policySection(
                        icon: Icons.delete_outline,
                        title: 'Delete Your Data Anytime',
                        content:
                            'You can log out anytime, which will delete all your data from the app. You have complete control to remove any information you no longer wish to store.',
                      ),
                      _policySection(
                        icon: Icons.contact_support,
                        title: 'Questions About Privacy?',
                        content:
                            'If you have any concerns about your privacy or data security, please contact us. Your trust and confidence are essential to us.',
                      ),
                      const SizedBox(height: 40),

                      // Data Protection Badge
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFFE87DB0).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.mediumPink, width: 2),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_user, size: 32, color: AppColors.mediumPink),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'We Care About Your Privacy',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Your health data is confidential and secure.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
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

  Widget _policySection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 28,
              color: AppColors.primaryPurple,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textGrey,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
