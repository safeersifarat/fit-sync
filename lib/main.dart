//main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/auth_controller.dart';
import 'screens/welcome_screen.dart';
import 'state/calorie_tracker_controller.dart';
import 'state/onboarding_controller.dart';
import 'core/theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FitSyncApp());
}

class FitSyncApp extends StatelessWidget {
  const FitSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()..initialize()),
        ChangeNotifierProvider(
          create: (_) => OnboardingController()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => CalorieTrackerController()..initialize(),
        ),
        ChangeNotifierProvider(create: (_) => AuthController()..initialize()),
      ],
      child: Consumer2<ThemeController, OnboardingController>(
        builder: (context, themeController, onboardingController, _) {
          // Sync theme with onboarding controller
          WidgetsBinding.instance.addPostFrameCallback((_) {
            themeController.syncWithOnboarding(
              onboardingController.darkModeEnabled,
            );
          });

          return MaterialApp(
            title: 'Fit Sync',
            debugShowCheckedModeBanner: false,
            theme: themeController.currentTheme,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(1.0)),
                child: child!,
              );
            },
            home: const WelcomeScreen(),
          );
        },
      ),
    );
  }
}
