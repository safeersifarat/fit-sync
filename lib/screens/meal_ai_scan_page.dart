import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/ai_camera_service.dart';
import '../state/calorie_tracker_controller.dart';

class MealAiScanPage extends StatefulWidget {
  const MealAiScanPage({
    super.key,
    required this.mealType,
    required this.title,
    required this.timeLabel,
  });

  final MealType mealType;
  final String title;
  final String timeLabel;

  @override
  State<MealAiScanPage> createState() => _MealAiScanPageState();
}

class _MealAiScanPageState extends State<MealAiScanPage>
    with SingleTickerProviderStateMixin {
  final _service = AiCameraService();
  DetectedFood? _detected;
  bool _isProcessing = false;
  late final AnimationController _lineController;

  @override
  void initState() {
    super.initState();
    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _init();
  }

  Future<void> _init() async {
    await _service.initialize();
    setState(() {});
    _startMockDetection();
  }

  Future<void> _startMockDetection() async {
    setState(() => _isProcessing = true);
    final result = await _service.mockDetectFood();
    if (!mounted) return;
    setState(() {
      _detected = result;
      _isProcessing = false;
    });
  }

  @override
  void dispose() {
    _lineController.dispose();
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _service.controller;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('AI Scan - ${widget.title}'),
      ),
      body: controller == null || !controller.value.isInitialized
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Stack(
              children: [
                CameraPreview(controller),
                _ScanningOverlay(animation: _lineController),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _BottomStatus(
                    detected: _detected,
                    isProcessing: _isProcessing,
                    onAdd: () {
                      if (_detected == null) return;
                      final ctrl = context.read<CalorieTrackerController>();
                      final date = ctrl.selectedDate;
                      final timeOfDay = TimeOfDay.now();
                      final entry = MealEntry(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        type: widget.mealType,
                        date: date,
                        timeOfDay: timeOfDay,
                        name: _detected!.name,
                        carbs: 0,
                        fats: 0,
                        protein: 0,
                        estimatedCalories: _detected!.calories.toDouble(),
                      );
                      ctrl.addEntry(entry);
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _ScanningOverlay extends StatelessWidget {
  const _ScanningOverlay({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final top = animation.value * (height * 0.6) + height * 0.2;
        return Stack(
          children: [
            Container(color: Colors.black.withValues(alpha: 0.25)),
            Positioned(
              left: 40,
              right: 40,
              top: height * 0.2,
              bottom: height * 0.2,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
            Positioned(
              left: 40,
              right: 40,
              top: top,
              child: Container(height: 2, color: Colors.white),
            ),
          ],
        );
      },
    );
  }
}

class _BottomStatus extends StatelessWidget {
  const _BottomStatus({
    required this.detected,
    required this.isProcessing,
    required this.onAdd,
  });

  final DetectedFood? detected;
  final bool isProcessing;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.1),
            Colors.black.withValues(alpha: 0.9),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isProcessing
                ? 'Scanning...'
                : detected != null
                ? 'Detected: ${detected!.name} - ${detected!.calories} kcal'
                : 'Tap Add to log this meal',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: detected == null ? null : onAdd,
              child: const Text('Add to Meal Log'),
            ),
          ),
        ],
      ),
    );
  }
}
