import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Providers
import 'services/language_provider.dart';
import 'services/auth_provider.dart';
import 'services/pin_provider.dart';
import 'services/period_data_provider.dart';
import 'services/notification_provider.dart';
import 'services/community_provider.dart';
import 'services/theme_provider.dart'; // <-- Added ThemeProvider

// Cubits
import 'cubits/search_cubit.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/pin_setup_screen.dart';
import 'screens/pin_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/profile_completion_screen.dart';
import 'screens/onboarding_screen1.dart';
import 'screens/login.dart';
import 'screens/signup.dart';
import 'screens/forgot_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔒 Lock orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // 🎨 Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // 🔥 Firebase init
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    BlocProvider<SearchCubit>(
      create: (context) => SearchCubit(),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppThemeProvider()), // <-- Added here
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => PinProvider()),
          ChangeNotifierProvider(create: (_) => PeriodDataProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ],
        child: const ShurokkhaApp(),
      ),
    ),
  );
}

class ShurokkhaApp extends StatelessWidget {
  const ShurokkhaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LanguageProvider, AppThemeProvider>(
      builder: (context, languageProvider, themeProvider, child) {
        return MaterialApp(
          title: 'Shurokkha',
          debugShowCheckedModeBanner: false,
          locale: languageProvider.locale,
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('bn', 'BD'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: themeProvider.primaryColor, // <-- Uses Dynamic Color
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            fontFamily: 'Roboto',
            scaffoldBackgroundColor: Colors.transparent,
          ),
          home: const SplashScreen(),
          routes: {
            '/onboarding': (context) => const OnboardingScreen1(),
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            '/forgot-password': (context) => const ForgotPasswordScreen(),
            '/profile': (context) => const ProfileCompletionScreen(),
            '/pin-setup': (context) => const PinSetupScreen(),
            '/pin-login': (context) => const PinScreen(),
            '/privacy-policy': (context) => const PrivacyPolicyScreen(),
            '/home': (context) {
              final args = ModalRoute.of(context)?.settings.arguments as Map?;
              return HomeScreen(userName: args?['userName'] ?? 'User');
            },
          },
        );
      },
    );
  }
}