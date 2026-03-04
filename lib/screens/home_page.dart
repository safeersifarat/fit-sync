// home_page.dart
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/profile_controller.dart';
import '../controllers/workout_controller.dart';
import '../widgets/auth_background.dart';
import 'ai_agent_page.dart';
import 'settings_page.dart';
import 'statistics_page.dart';
import 'profile_page.dart';
import '../workout/camera/workout_camera_page.dart';

// ─────────────────────────────────────────────
//  Data model for a single journey day
// ─────────────────────────────────────────────
enum DayState { completed, current, locked }

class JourneyDay {
  final int day;
  final DayState state;
  final int stars; // 0‑3

  const JourneyDay({required this.day, required this.state, this.stars = 0});
}

// ─────────────────────────────────────────────
//  Dummy data: 6 completed, 1 current, rest locked
// ─────────────────────────────────────────────

// ─────────────────────────────────────────────
//  Shell (replaces old HomeShell)
// ─────────────────────────────────────────────
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with TickerProviderStateMixin {
  // ── Tab state
  int _tabIndex = 0;

  List<JourneyDay> _days = [];
  late final ScrollController _scroll;
  late final AnimationController _pulseCtrl;
  late final AnimationController _floatCtrl;
  late final AnimationController _starCtrl;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _floatAnim;
  late final Animation<double> _starAnim;

  // Shake for locked days
  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  void _buildDaysFromBackend(WorkoutController ctrl) {
    final days = <JourneyDay>[];

    for (int i = 1; i <= ctrl.totalDays; i++) {
      if (ctrl.completedDays.contains(i)) {
        days.add(JourneyDay(day: i, state: DayState.completed, stars: 3));
      } else if (i == ctrl.currentDay) {
        days.add(JourneyDay(day: i, state: DayState.current));
      } else {
        days.add(JourneyDay(day: i, state: DayState.locked));
      }
    }

    _days = days;
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<WorkoutController>().loadJourney();
    });
    _scroll = ScrollController();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween(
      begin: 0.95,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _floatAnim = Tween(
      begin: -8.0,
      end: 8.0,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _starCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _starAnim = Tween(
      begin: 0.85,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _starCtrl, curve: Curves.elasticOut));

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 12.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 12.0, end: -12.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -12.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.linear));

    // Scroll to current day after build
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentDay());
  }

  void _scrollToCurrentDay() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;

      // Find the index of the current day
      final currentIndex = _days.indexWhere((d) => d.state == DayState.current);
      if (currentIndex < 0) {
        // No current day found — fall back to top
        _scroll.jumpTo(0);
        return;
      }

      // Mirror of _JourneyPath._yFor / layout constants
      const double kNodeHeight = 120.0;
      const double kTopPad = 80.0;
      final double n = _days.length.toDouble();
      final double nodeY = kTopPad + (n - 1 - currentIndex) * kNodeHeight;

      // Target: centre the node in the viewport
      final double viewportHeight = _scroll.position.viewportDimension;
      final double target = (nodeY - viewportHeight / 2 + kNodeHeight / 2)
          .clamp(0.0, _scroll.position.maxScrollExtent);

      _scroll.jumpTo(target);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _pulseCtrl.dispose();
    _floatCtrl.dispose();
    _starCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onDayTap(JourneyDay day) {
    switch (day.state) {
      case DayState.current:
        _showStartWorkoutSheet(day);
        break;
      case DayState.completed:
        _showCompletedSheet(day);
        break;
      case DayState.locked:
        _shakeCtrl.forward(from: 0);
        _showLockedSnack();
        break;
    }
  }

  void _showStartWorkoutSheet(JourneyDay day) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _StartWorkoutSheet(day: day),
    );
  }

  void _showCompletedSheet(JourneyDay day) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CompletedDaySheet(day: day),
    );
  }

  void _showLockedSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Text('🔒', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Complete previous days first!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileData = context.watch<ProfileController>().profileData;
    final name = profileData?['name'] ?? 'User';
    final workoutCtrl = context.watch<WorkoutController>();

    if (workoutCtrl.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    _buildDaysFromBackend(workoutCtrl);
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
          // ── App-wide background
          const AuthBackground(child: SizedBox.expand()),

          // ── Tab pages
          IndexedStack(
            index: _tabIndex,
            children: [
              // Tab 0 – Journey
              _JourneyTab(
                days: _days,
                scroll: _scroll,
                pulseAnim: _pulseAnim,
                floatAnim: _floatAnim,
                starAnim: _starAnim,
                shakeAnim: _shakeAnim,
                onDayTap: _onDayTap,
                name: name,
              ),
              // Tab 1 – Progress
              const StatisticsPage(),
              // Tab 2 – AI / Rewards
              const AiAgentPage(),
              // Tab 3 – Settings
              const SettingsPage(),
            ],
          ),

          // ── Bottom nav bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomNavBar(
              currentIndex: _tabIndex,
              onChanged: (i) {
                if (i == 0 && _tabIndex != 0) {
                  _scrollToCurrentDay();
                }
                setState(() => _tabIndex = i);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Journey tab content (extracted from old build)
// ─────────────────────────────────────────────
class _JourneyTab extends StatelessWidget {
  const _JourneyTab({
    required this.days,
    required this.scroll,
    required this.pulseAnim,
    required this.floatAnim,
    required this.starAnim,
    required this.shakeAnim,
    required this.onDayTap,
    required this.name,
  });
  final List<JourneyDay> days;
  final ScrollController scroll;
  final Animation<double> pulseAnim;
  final Animation<double> floatAnim;
  final Animation<double> starAnim;
  final Animation<double> shakeAnim;
  final ValueChanged<JourneyDay> onDayTap;
  final String name;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        // ── Background gradient — theme-aware
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? const [
                      Color(0xFF0A1F0E),
                      Color(0xFF0D2614),
                      Color(0xFF051209),
                    ]
                  : const [
                      Color(0xFF5B3FE8),
                      Color(0xFF7B5CF0),
                      Color(0xFF9B7AF8),
                    ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),

        // ── Content
        SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  _Header(name: name),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? const [Color(0xFF2EA043), Color(0xFF1A7B30)]
                                  : const [
                                      Color(0xFF7B5CF0),
                                      Color(0xFF5B3FE8),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'SECTION 1  •  90-Day Journey',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _JourneyPath(
                      days: days,
                      scroll: scroll,
                      pulseAnim: pulseAnim,
                      floatAnim: floatAnim,
                      starAnim: starAnim,
                      shakeAnim: shakeAnim,
                      onDayTap: onDayTap,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Bottom Navigation Bar
// ─────────────────────────────────────────────
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.currentIndex, required this.onChanged});
  final int currentIndex;
  final ValueChanged<int> onChanged;

  static const _items = [
    _NavItemData(icon: Icons.home_rounded, label: 'Home'),
    _NavItemData(icon: Icons.bar_chart_rounded, label: 'Progress'),
    _NavItemData(icon: Icons.auto_awesome_rounded, label: 'Food AI'),
    _NavItemData(icon: Icons.settings_rounded, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Colors.white.withValues(alpha: 0.15),
                          Colors.white.withValues(alpha: 0.05),
                        ]
                      : [
                          const Color(0xFF4A2FD4).withValues(alpha: 0.92),
                          const Color(0xFF6248E8).withValues(alpha: 0.88),
                        ],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.2)
                        : const Color(0xFF5B3FE8).withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  _items.length,
                  (i) => _NavItem(
                    data: _items[i],
                    index: i,
                    currentIndex: currentIndex,
                    onTap: onChanged,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.data,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });
  final _NavItemData data;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: isDark
                      ? const [Color(0xFFCCFF00), Color(0xFF99CC00)]
                      : [Colors.white, Colors.white.withValues(alpha: 0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isActive ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: isDark
                        ? const Color(0xFFCCFF00).withValues(alpha: 0.35)
                        : Colors.white.withValues(alpha: 0.5),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              data.icon,
              color: isActive
                  ? (isDark ? Colors.black87 : const Color(0xFF5B3FE8))
                  : Colors.white.withValues(alpha: 0.65),
              size: 22,
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                data.label,
                style: TextStyle(
                  color: isDark ? Colors.black87 : const Color(0xFF5B3FE8),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Header
// ─────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ProfileController>();
    final avatarPath = ctrl.profileData?['avatarUrl'] as String?;
    // Header is always on the coloured gradient background,
    // so text is always white regardless of theme.

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Greeting
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Hi, $name ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const TextSpan(text: '👋', style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
              const Text(
                'Welcome Back',
                style: TextStyle(
                  color: Color(0xFFD4BFFF), // light lavender on purple bg
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // Right side: streak pill + avatar
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔥 Streak pill
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            color: Colors.orangeAccent,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${context.watch<WorkoutController>().streak}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Profile avatar
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfilePage(),
                          ),
                        );
                      },
                      child: ClipOval(
                        child: Container(
                          height: 36,
                          width: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.8),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: avatarPath != null
                                ? Image.file(
                                    File(avatarPath),
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF9B7AF8),
                                          Color(0xFF5B3FE8),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.person_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Journey Path
// ─────────────────────────────────────────────
class _JourneyPath extends StatelessWidget {
  const _JourneyPath({
    required this.days,
    required this.scroll,
    required this.pulseAnim,
    required this.floatAnim,
    required this.starAnim,
    required this.shakeAnim,
    required this.onDayTap,
  });

  final List<JourneyDay> days;
  final ScrollController scroll;
  final Animation<double> pulseAnim;
  final Animation<double> floatAnim;
  final Animation<double> starAnim;
  final Animation<double> shakeAnim;
  final void Function(JourneyDay) onDayTap;

  static const double kNodeHeight = 120.0;
  static const double kAmplitude = 80.0;

  /// Extra space above Day 90 (top of content)
  static const double kTopPad = 80.0;

  /// Extra space below Day 1 (bottom of content — near nav bar)
  static const double kBottomPad = 140.0;

  // ── X position: zig-zag sine curve (same as before)
  double _xFor(int index, double halfWidth) {
    final t = index % 5;
    final angle = (t / 4.0) * math.pi;
    return halfWidth - kAmplitude * math.cos(angle);
  }

  // ── Y position: FLIPPED so index 0 (Day 1) is at the BOTTOM
  //   index 0  → large y  (bottom of stack)
  //   index 89 → small y  (top of stack)
  double _yFor(int index, double totalDays) {
    return kTopPad + (totalDays - 1 - index) * kNodeHeight;
  }

  @override
  Widget build(BuildContext context) {
    final n = days.length.toDouble();
    final pathHeight = kTopPad + n * kNodeHeight + kBottomPad;

    return LayoutBuilder(
      builder: (context, constraints) {
        final halfWidth = constraints.maxWidth / 2;
        return ListView(
          controller: scroll,
          // Top padding only — bottom is near the nav bar
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          children: [
            SizedBox(
              height: pathHeight,
              child: Stack(
                children: [
                  // ── Path line
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _PathLinePainter(
                        days: days,
                        xFor: (i) => _xFor(i, halfWidth),
                        yFor: (i) => _yFor(i, days.length.toDouble()),
                        nodeHeight: kNodeHeight,
                        currentDayIndex:
                            context.watch<WorkoutController>().currentDay - 1,
                      ),
                    ),
                  ),

                  // ── Day nodes
                  for (int i = 0; i < days.length; i++)
                    ..._buildNode(i, days[i], halfWidth, n),

                  // ── Mascot near current day
                  _buildMascot(
                    context.watch<WorkoutController>().currentDay - 1,
                    halfWidth,
                    constraints.maxWidth,
                    n,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildNode(
    int index,
    JourneyDay day,
    double halfWidth,
    double totalDays,
  ) {
    final x = _xFor(index, halfWidth);
    final y = _yFor(index, totalDays);

    if (day.state == DayState.locked) {
      return [
        Positioned(
          left: x - 36,
          top: y,
          child: AnimatedBuilder(
            animation: shakeAnim,
            builder: (_, child) => Transform.translate(
              offset: Offset(shakeAnim.value, 0),
              child: child,
            ),
            child: GestureDetector(
              onTap: () => onDayTap(day),
              child: _LockedNode(day: day),
            ),
          ),
        ),
      ];
    }

    if (day.state == DayState.current) {
      return [
        Positioned(
          left: x - 40,
          top: y - 10,
          child: AnimatedBuilder(
            animation: pulseAnim,
            builder: (_, child) =>
                Transform.scale(scale: pulseAnim.value, child: child),
            child: GestureDetector(
              onTap: () => onDayTap(day),
              child: _CurrentNode(day: day.day),
            ),
          ),
        ),
      ];
    }

    // Completed
    return [
      Positioned(
        left: x - 36,
        top: y,
        child: GestureDetector(
          onTap: () => onDayTap(day),
          child: _CompletedNode(day: day, starAnim: starAnim),
        ),
      ),
    ];
  }

  Widget _buildMascot(
    int nearIndex,
    double halfWidth,
    double fullWidth,
    double totalDays,
  ) {
    final x = _xFor(nearIndex, halfWidth);
    final y = _yFor(nearIndex, totalDays);
    // Place mascot on the opposite side of the node
    final mascotX = x > halfWidth ? x - 160 : x + 90;

    return Positioned(
      left: mascotX.clamp(0.0, fullWidth - 100),
      top: y - 60,
      child: AnimatedBuilder(
        animation: floatAnim,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, floatAnim.value),
          child: child,
        ),
        child: _MascotWidget(day: nearIndex + 1),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Path line custom painter
// ─────────────────────────────────────────────
class _PathLinePainter extends CustomPainter {
  final List<JourneyDay> days;
  final double Function(int) xFor;
  final double Function(int) yFor; // ← now injected (bottom-to-top)
  final double nodeHeight;
  final int currentDayIndex;

  const _PathLinePainter({
    required this.days,
    required this.xFor,
    required this.yFor,
    required this.nodeHeight,
    required this.currentDayIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Build the full path using flipped y (Day 1 at bottom, Day 90 at top)
    final path = Path();
    for (int i = 0; i < days.length; i++) {
      final x = xFor(i);
      // Centre of each node circle
      final y = yFor(i) + 36;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = xFor(i - 1);
        final prevY = yFor(i - 1) + 36;
        final cpX = (prevX + x) / 2;
        path.cubicTo(cpX, prevY, cpX, y, x, y);
      }
    }

    // In bottom-to-top layout:
    //   ● Completed nodes (index 0..currentDayIndex) are near the BOTTOM → large y
    //   ● Locked nodes (index currentDayIndex+1..89) are near the TOP → small y
    //
    // So 'completed' colour fills everything BELOW the current day cutoff.
    final currentY = yFor(currentDayIndex) + 36 + 36;

    final completedPaint = Paint()
      ..color = const Color(0xFF39D353)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final remainingPaint = Paint()
      ..color = const Color(0xFF1A3A21).withValues(alpha: 0.6)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Completed segment = bottom portion (y >= currentY)
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, currentY, size.width, size.height));
    canvas.drawPath(path, completedPaint);
    canvas.restore();

    // Remaining segment = top portion (y < currentY)
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, size.width, currentY));
    canvas.drawPath(path, remainingPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────
//  Node widgets
// ─────────────────────────────────────────────

class _CompletedNode extends StatelessWidget {
  const _CompletedNode({required this.day, required this.starAnim});
  final JourneyDay day;
  final Animation<double> starAnim;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [Color(0xFF39D353), Color(0xFF1A7B30)],
            ),
            border: Border.all(color: const Color(0xFFFFD700), width: 3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF39D353).withValues(alpha: 0.5),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                'Day\n${day.day}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  height: 1.2,
                ),
              ),
              // Checkmark badge
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD700),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.black, size: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Stars
        AnimatedBuilder(
          animation: starAnim,
          builder: (context, child) => Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (si) {
              final filled = si < day.stars;
              return Transform.scale(
                scale: filled ? starAnim.value * 0.92 : 1.0,
                child: Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: filled ? const Color(0xFFFFD700) : Colors.white24,
                  size: 14,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _CurrentNode extends StatelessWidget {
  const _CurrentNode({required this.day});
  final int day;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const purple = Color(0xFF5B3FE8);
    const green = Color(0xFFCCFF00);
    final accent = isDark ? green : purple;
    final accentDim = isDark
        ? const Color(0xFF8BC800)
        : const Color(0xFF7B5FFF);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [accent, accentDim]),
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.55),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
                BoxShadow(
                  color: accent.withValues(alpha: 0.25),
                  blurRadius: 36,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Day $day',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Start →',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: const Text(
            'Current Day',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _LockedNode extends StatelessWidget {
  const _LockedNode({required this.day});
  final JourneyDay day;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1A2A1E).withValues(alpha: 0.8),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_rounded,
                color: Colors.white.withValues(alpha: 0.35),
                size: 20,
              ),
              const SizedBox(height: 2),
              Text(
                'Day ${day.day}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Mascot widget
// ─────────────────────────────────────────────
class _MascotWidget extends StatelessWidget {
  const _MascotWidget({required this.day});
  final int day;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Speech bubble
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Text(
            'Day $day ready! 💪',
            style: const TextStyle(
              color: Color(0xFF1A2A1E),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        // Bubble tail
        CustomPaint(size: const Size(12, 8), painter: _BubbleTailPainter()),
        const SizedBox(height: 2),
        // Mascot body (drawn with Flutter widgets — no external image needed)
        _MascotBody(),
      ],
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MascotBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 90,
      child: CustomPaint(painter: _MascotPainter()),
    );
  }
}

class _MascotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    // Body
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRRect(
      RRect.fromLTRBR(cx - 24, 40, cx + 24, 80, const Radius.circular(18)),
      bodyPaint,
    );

    // Head
    final headPaint = Paint()..color = const Color(0xFFFFCC80); // skin tone
    canvas.drawCircle(Offset(cx, 26), 22, headPaint);

    // Headband
    final bandPaint = Paint()..color = const Color(0xFFCCFF00);
    canvas.drawRect(Rect.fromLTRB(cx - 22, 10, cx + 22, 18), bandPaint);

    // Eyes
    final eyeWhite = Paint()..color = Colors.white;
    final eyePupil = Paint()..color = const Color(0xFF1A1A1A);
    canvas.drawCircle(Offset(cx - 8, 25), 7, eyeWhite);
    canvas.drawCircle(Offset(cx + 8, 25), 7, eyeWhite);
    canvas.drawCircle(Offset(cx - 7, 26), 3, eyePupil);
    canvas.drawCircle(Offset(cx + 9, 26), 3, eyePupil);

    // Smile
    final smilePaint = Paint()
      ..color = const Color(0xFFBF360C)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final smilePath = Path()
      ..moveTo(cx - 8, 34)
      ..quadraticBezierTo(cx, 40, cx + 8, 34);
    canvas.drawPath(smilePath, smilePaint);

    // Arms (with dumbbells)
    final armPaint = Paint()
      ..color = const Color(0xFF388E3C)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    // Left arm
    canvas.drawLine(Offset(cx - 24, 52), Offset(cx - 42, 44), armPaint);
    // Right arm
    canvas.drawLine(Offset(cx + 24, 52), Offset(cx + 42, 44), armPaint);

    // Dumbbells
    final dumbPaint = Paint()..color = const Color(0xFF757575);
    // Left dumbbell
    canvas.drawRRect(
      RRect.fromLTRBR(cx - 50, 40, cx - 36, 48, const Radius.circular(3)),
      dumbPaint,
    );
    // Right dumbbell
    canvas.drawRRect(
      RRect.fromLTRBR(cx + 36, 40, cx + 50, 48, const Radius.circular(3)),
      dumbPaint,
    );

    // Legs
    final legPaint = Paint()
      ..color = const Color(0xFF1565C0)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 10, 78), Offset(cx - 14, 92), legPaint);
    canvas.drawLine(Offset(cx + 10, 78), Offset(cx + 14, 92), legPaint);

    // Shoes
    final shoePaint = Paint()..color = const Color(0xFF212121);
    canvas.drawOval(Rect.fromLTRB(cx - 20, 88, cx - 4, 96), shoePaint);
    canvas.drawOval(Rect.fromLTRB(cx + 4, 88, cx + 20, 96), shoePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────
//  Bottom sheets
// ─────────────────────────────────────────────
class _StartWorkoutSheet extends StatefulWidget {
  const _StartWorkoutSheet({required this.day});
  final JourneyDay day;

  @override
  State<_StartWorkoutSheet> createState() => _StartWorkoutSheetState();
}

class _StartWorkoutSheetState extends State<_StartWorkoutSheet> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<WorkoutController>().loadTodayWorkout();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;
    final ctrl = context.watch<WorkoutController>();

    List<dynamic> exercises = [];
    if (ctrl.todayWorkout != null && ctrl.todayWorkout!['exercises'] != null) {
      final String exStr = ctrl.todayWorkout!['exercises'];
      try {
        exercises = jsonDecode(exStr);
      } catch (e) {
        // Fallback or leave empty
      }
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomPad),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.18),
                        Colors.white.withValues(alpha: 0.06),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Handle bar
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '🏋️ Day ${widget.day.day} Workout',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Today\'s Plan',
                          style: TextStyle(color: Colors.white60, fontSize: 13),
                        ),
                        const SizedBox(height: 4),

                        if (ctrl.isLoading)
                          const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(
                              color: Color(0xFFCCFF00),
                            ),
                          )
                        else if (exercises.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text(
                              'No exercises found for today.',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        else
                          ...exercises.map((ex) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: _SheetWorkoutRow(
                                icon:
                                    '💪', // Placeholder, map logic based on body part if needed
                                label: ex['name'] ?? 'Exercise',
                                detail:
                                    '${ex['sets'] ?? 3} sets × ${ex['reps'] ?? 10}',
                                onStart: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => WorkoutCameraPage(
                                        exerciseName: "pushups",
                                        targetReps: 15,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetWorkoutRow extends StatelessWidget {
  const _SheetWorkoutRow({
    required this.icon,
    required this.label,
    required this.detail,
    required this.onStart,
  });
  final String icon;
  final String label;
  final String detail;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon bubble
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          // Label + detail
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: const TextStyle(
                    color: Color(0xFFCCFF00),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Individual Start button
          GestureDetector(
            onTap: onStart,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFCCFF00), Color(0xFF8BC800)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFCCFF00).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'Start',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedDaySheet extends StatelessWidget {
  const _CompletedDaySheet({required this.day});
  final JourneyDay day;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomPad),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.18),
                        Colors.white.withValues(alpha: 0.06),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '✅ Day ${day.day} Completed!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (i) {
                            final filled = i < day.stars;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Icon(
                                filled
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: filled
                                    ? const Color(0xFFFFD700)
                                    : Colors.white30,
                                size: 38,
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          day.stars == 3
                              ? 'Perfect run! 🔥'
                              : day.stars == 2
                              ? 'Great effort! 👍'
                              : 'Keep pushing! 💪',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(
                              'Close',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
