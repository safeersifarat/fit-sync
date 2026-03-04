// splash_screen.dart
import 'package:flutter/material.dart';
import '../widgets/auth_background.dart';
import 'login_screen.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _titleSlide;
  late Animation<double> _titleOpacity;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _progressOpacity;
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();

    // Logo entrance animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // Fade-in for text and progress
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _titleSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );

    _progressOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );

    // Pulse animation for the logo glow
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseScale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    // 🔥 Initialize authentication early
    final auth = context.read<AuthController>();
    await auth.initialize();

    if (!mounted) return;

    if (auth.isAuthenticated) {
      // Fast path if already logged in - short delay for smooth transition
      _logoController.value = 1.0;
      _fadeController.value = 1.0;
      await Future.delayed(const Duration(milliseconds: 400));
      
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeShell(),
          transitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
        ),
      );
      return;
    }

    // Normal slow path for new/logged-out users
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    _fadeController.forward();
    _pulseController.repeat(reverse: true);

    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const purple = Color(0xFF5B3FE8);
    const lime = Color(0xFFCCFF00);
    final accentColor = isDark ? lime : purple;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuthBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              // ── Animated logo ──
              AnimatedBuilder(
                animation: Listenable.merge([
                  _logoController,
                  _pulseController,
                ]),
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: child,
                    ),
                  );
                },
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            accentColor.withValues(alpha: 0.25),
                            accentColor.withValues(alpha: 0.08),
                          ],
                        ),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.5),
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(
                              alpha: 0.3 * _pulseScale.value,
                            ),
                            blurRadius: 30 * _pulseScale.value,
                            spreadRadius: 5 * (_pulseScale.value - 1.0),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.fitness_center_rounded,
                        color: accentColor,
                        size: 48,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),

              // ── App title ──
              AnimatedBuilder(
                animation: _fadeController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _titleOpacity.value,
                    child: Transform.translate(
                      offset: Offset(0, _titleSlide.value),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  'FitSync',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.5,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── Subtitle ──
              AnimatedBuilder(
                animation: _fadeController,
                builder: (context, child) {
                  return Opacity(opacity: _subtitleOpacity.value, child: child);
                },
                child: Text(
                  'Your AI Fitness Companion',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.3,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : Colors.black45,
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // ── Loading indicator ──
              AnimatedBuilder(
                animation: _fadeController,
                builder: (context, child) {
                  return Opacity(opacity: _progressOpacity.value, child: child);
                },
                child: Column(
                  children: [
                    SizedBox(
                      width: 160,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          minHeight: 3,
                          backgroundColor: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.06),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            accentColor.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.2,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.4)
                            : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
