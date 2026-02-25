import 'package:flutter/material.dart';
import 'dart:ui';

class WorkoutNotification extends StatefulWidget {
  const WorkoutNotification({
    super.key,
    required this.workoutTitle,
    required this.workoutDetails,
    required this.scheduledTime,
    this.onTap,
    this.onDismiss,
  });

  final String workoutTitle;
  final String workoutDetails;
  final String scheduledTime;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  @override
  State<WorkoutNotification> createState() => _WorkoutNotificationState();
}

class _WorkoutNotificationState extends State<WorkoutNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Start animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (!_isVisible) return;

    setState(() => _isVisible = false);
    await _controller.reverse();
    widget.onDismiss?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return SlideTransition(
      position: _slideAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        onVerticalDragUpdate: (details) {
          if (details.delta.dy < -5) {
            _dismiss();
          }
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.15),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.workoutTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.workoutDetails,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          widget.scheduledTime,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.9),
                                Colors.white.withValues(alpha: 0.7),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.fitness_center,
                            color: Colors.black87,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper widget to show workout notification overlay
class WorkoutNotificationOverlay extends StatefulWidget {
  const WorkoutNotificationOverlay({
    super.key,
    required this.child,
    this.workoutTitle,
    this.workoutDetails,
    this.scheduledTime,
    this.onWorkoutTap,
  });

  final Widget child;
  final String? workoutTitle;
  final String? workoutDetails;
  final String? scheduledTime;
  final VoidCallback? onWorkoutTap;

  @override
  State<WorkoutNotificationOverlay> createState() =>
      _WorkoutNotificationOverlayState();
}

class _WorkoutNotificationOverlayState
    extends State<WorkoutNotificationOverlay> {
  bool _showNotification = false;

  void showNotification() {
    setState(() => _showNotification = true);
  }

  void hideNotification() {
    setState(() => _showNotification = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showNotification &&
            widget.workoutTitle != null &&
            widget.workoutDetails != null &&
            widget.scheduledTime != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: WorkoutNotification(
              workoutTitle: widget.workoutTitle!,
              workoutDetails: widget.workoutDetails!,
              scheduledTime: widget.scheduledTime!,
              onTap: widget.onWorkoutTap,
              onDismiss: hideNotification,
            ),
          ),
      ],
    );
  }
}

/// Global function to show workout notification as overlay
void showWorkoutNotification(
  BuildContext context, {
  required String workoutTitle,
  required String workoutDetails,
  required String scheduledTime,
  VoidCallback? onTap,
}) {
  final overlay = Overlay.of(context);
  final overlayEntryRef = <OverlayEntry?>[];

  final overlayEntry = OverlayEntry(
    builder: (context) {
      void removeOverlay() {
        overlayEntryRef.first?.remove();
        overlayEntryRef.clear();
      }

      return Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: WorkoutNotification(
            workoutTitle: workoutTitle,
            workoutDetails: workoutDetails,
            scheduledTime: scheduledTime,
            onTap: () {
              removeOverlay();
              onTap?.call();
            },
            onDismiss: removeOverlay,
          ),
        ),
      );
    },
  );

  overlayEntryRef.add(overlayEntry);
  overlay.insert(overlayEntry);

  // Auto-dismiss after 5 seconds
  Future.delayed(const Duration(seconds: 5), () {
    if (overlayEntry.mounted) {
      overlayEntry.remove();
      overlayEntryRef.clear();
    }
  });
}
