//main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/auth_controller.dart';
import 'screens/splash_screen.dart';
import 'controllers/profile_controller.dart';
import 'core/theme/theme_controller.dart';
import 'controllers/workout_controller.dart';
import 'controllers/stats_controller.dart';
import 'controllers/ai_controller.dart';

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
          create: (_) => ProfileController()..loadProfile(),
        ),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => WorkoutController()),
        ChangeNotifierProvider(create: (_) => StatsController()),
        ChangeNotifierProvider(create: (_) => AiController()),
      ],
      child: Builder(
        builder: (context) {
          final themeController = context.watch<ThemeController>();
          
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
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
