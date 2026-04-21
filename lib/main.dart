import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme/app_theme.dart';
import 'services/supabase_service.dart';
import 'services/language_service.dart';
import 'screens/onboarding_screen.dart';
import 'widgets/bottom_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseService.initialize();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase initialization failed.");
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageService(),
      child: const DamascusTrafficApp(),
    ),
  );
}

class DamascusTrafficApp extends StatelessWidget {
  const DamascusTrafficApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, ls, _) {
        return MaterialApp(
          title: ls.t('app_name'),
          theme: ls.isArabic ? AppTheme.arabicTheme : AppTheme.themeData,
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return Directionality(
              textDirection: ls.direction,
              child: child ?? const SizedBox(),
            );
          },
          home: const AuthWrapper(),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (SupabaseService.isPlaceholder) {
      return const OnboardingScreen();
    }

    return StreamBuilder<AuthState>(
      stream: SupabaseService.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final session = snapshot.hasData ? snapshot.data!.session : null;
        if (session != null) return const BottomNavBar();
        return const OnboardingScreen();
      },
    );
  }
}