import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'providers/theme_provider.dart';

// Screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/verify_email_screen.dart';
import 'screens/auth/forget_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/dashboard/pro_dashboard.dart';
import 'screens/subscription/go_premium_screen.dart';
import 'screens/subscription/confirm_payment_screen.dart';
import 'screens/subscription/premium_confirmation_congrats.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/.env');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'SEO AI Mastermind',
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF2D5EFF),
        scaffoldBackgroundColor: const Color(0xFFF4F7FE),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF2D5EFF),
        scaffoldBackgroundColor: const Color(0xFF121212),
        useMaterial3: true,
      ),
      home: const AuthGate(),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/go-premium': (context) => GoPremiumScreen(isDarkMode: isDarkMode),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/verify-email':
            final args = settings.arguments as Map<String, dynamic>?;
            final user = args?['user'];
            return MaterialPageRoute(
              builder: (_) =>
              (user != null && user is User) ? VerifyEmailScreen(user: user) : const LoginScreen(),
            );
          case '/pro-dashboard':
            return MaterialPageRoute(builder: (_) => const ProDashboard());
          case '/confirm_payment':
            final args = settings.arguments as Map<String, dynamic>?;
            final planType = args?['planType'] ?? 'monthly';
            return MaterialPageRoute(
              builder: (_) => ConfirmPaymentScreen(planType: planType),
            );
          case '/premium_congrats':
            final args = settings.arguments as Map<String, dynamic>?;
            final isDarkMode = args?['isDarkMode'] ?? false;
            return MaterialPageRoute(
              builder: (_) => PremiumCongratsScreen(isDarkMode: isDarkMode),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('404: Route not found')),
              ),
            );
        }
      },
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  Future<Widget> _getInitialScreen() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint("User is not logged in. Showing SplashScreen.");
      return const SplashScreen();
    }

    if (!user.emailVerified) {
      debugPrint("User email not verified. Showing VerifyEmailScreen.");
      return VerifyEmailScreen(user: user);
    }

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (!userDoc.exists || userDoc.data() == null) {
        debugPrint("User document missing. Redirecting to HomeScreen.");
        return const HomeScreen();
      }

      final userData = userDoc.data()!;
      final isProUser = userData['isProUser'] == true;

      debugPrint("User data fetched. isProUser: $isProUser");

      return isProUser ? const ProDashboard() : const HomeScreen();
    } catch (e) {
      debugPrint("Error fetching user document: $e");
      return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Widget>(
      future: _getInitialScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Something went wrong')),
          );
        } else {
          return snapshot.data!;
        }
      },
    );
  }
}
