import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/language_provider.dart';
import '../services/localization_extension.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void _navigateToNext() {
    final authProvider = context.read<AuthProvider>();
    
    // Flow: Splash -> Onboarding (if not done) -> Login/Signup -> Profile (after signup) -> Home
    if (!authProvider.isOnboardingCompleted) {
      // First time user - show onboarding
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else if (!authProvider.isLoggedIn) {
      // Onboarding done but not logged in - show login screen
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      // User is logged in - show home
      Navigator.pushReplacementNamed(context, '/home', arguments: {
        'userName': authProvider.userName ?? 'User',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEDD9FF), // Light purple at top
              Color(0xFFF0E0FF), // Soft purple
              Color(0xFFFFE6F5), // Pink
              Color(0xFFFFF5E0), // Peach/Orange at bottom
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main Column
              Column(
                children: [
                  SizedBox(height: screenHeight * 0.06),
              
              // App Name with Gradient Text
              Consumer<LanguageProvider>(
                builder: (context, languageProvider, _) {
                  return ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFF5E35B1),
                        Color(0xFF42A5F5),
                        Color(0xFFEC407A),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      context.translate('shurokkha'),
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  );
                },
              ),
              
              SizedBox(height: screenHeight * 0.03),
              
              // Community Illustration in Circle
              Container(
                width: screenWidth * 0.65,
                height: screenWidth * 0.65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/community_illustration.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade100,
                        child: Icon(
                          Icons.image_outlined,
                          color: Colors.grey.shade400,
                          size: 60,
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              SizedBox(height: screenHeight * 0.06),

              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 20),
              //   child: Text(
              //     'Your Safe Digital Sister - Period Health & Wellness',
              //     textAlign: TextAlign.center,
              //     style: TextStyle(
              //       fontSize: 14,
              //       fontWeight: FontWeight.w600,
              //       color: const Color(0xFF7A6B8F),
              //       height: 1.5,
              //       letterSpacing: 0.2,
              //     ),
              //   ),
              // ),
              
                            SizedBox(height: screenHeight * 0.07),

              // Let's Begin Button
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.15,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _navigateToNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5E35B1),
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: const Color(0xFF5E35B1).withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.translate('lets_started'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.arrow_forward_rounded, size: 22),
                      ],
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: screenHeight * 0.03),
              
              SizedBox(height: screenHeight * 0.02),
                ],
              ),
              
              // Language Switcher Button (Top Right)
              Positioned(
                top: 12,
                right: 16,
                child: Consumer<LanguageProvider>(
                  builder: (context, languageProvider, _) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => languageProvider.toggleLanguage(),
                          borderRadius: BorderRadius.circular(24),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.language,
                                  color: const Color(0xFF5E35B1),
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  languageProvider.isEnglish ? 'EN' : 'বাংলা',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF5E35B1),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
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