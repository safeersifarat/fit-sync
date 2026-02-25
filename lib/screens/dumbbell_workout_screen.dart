import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../services/dumbbell_pose_service.dart';
import 'workout_thank_you_screen.dart';

/// Full-screen dumbbell workout with camera, pose-based rep counting,
/// posture feedback, and Finish → Thank You flow.
class DumbbellWorkoutScreen extends StatefulWidget {
  const DumbbellWorkoutScreen({
    super.key,
    required this.title,
    this.targetReps,
  });

  final String title;
  final int? targetReps;

  @override
  State<DumbbellWorkoutScreen> createState() => _DumbbellWorkoutScreenState();
}

class _DumbbellWorkoutScreenState extends State<DumbbellWorkoutScreen> {
  CameraController? _camera;
  final _poseService = DumbbellPoseService();
  bool _isInitialized = false;
  String? _error;

  int _repCount = 0;
  String? _postureMessage;
  bool _isGoodPosture = true;
  String _repPhase = 'extended'; // extended | flexed
  DateTime _startTime = DateTime.now();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await controller.initialize();
      if (!mounted) return;
      setState(() {
        _camera = controller;
        _isInitialized = true;
      });
      _startPoseStream();
    } catch (e) {
      setState(() {
        _error = 'Camera error: $e';
        _isInitialized = false;
      });
    }
  }

  void _startPoseStream() {
    _camera?.startImageStream((image) async {
      if (_isProcessing || !mounted) return;
      _isProcessing = true;
      try {
        final result = await _poseService.processFrame(
          image,
          _camera!.description.lensDirection,
        );
        if (!mounted) return;
        if (result != null) {
          _updateRepAndPosture(result);
        }
      } catch (_) {}
      _isProcessing = false;
    });
  }

  void _updateRepAndPosture(DumbbellPoseResult result) {
    setState(() {
      _postureMessage = result.message;
      _isGoodPosture = result.isGoodPosture;

      final phase = result.repPhase ?? _repPhase;
      if (phase == 'extended' && _repPhase == 'flexed') {
        _repCount++;
      }
      _repPhase = phase;
    });
  }

  void _manualAddRep() {
    setState(() => _repCount++);
  }

  Future<void> _finishWorkout() async {
    await _camera?.stopImageStream();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutThankYouScreen(
          title: widget.title,
          repCount: _repCount,
          duration: DateTime.now().difference(_startTime),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _camera?.dispose();
    _poseService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildCameraOrPlaceholder(),
            _buildOverlay(),
            _buildTopBar(),
            _buildBottomControls(),
            if (_error != null) _buildErrorBanner(),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraOrPlaceholder() {
    if (!_isInitialized || _camera == null || !_camera!.value.isInitialized) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    return CameraPreview(_camera!);
  }

  Widget _buildOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.5),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.6),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                'Reps: $_repCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_postureMessage != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _isGoodPosture
                      ? Colors.green.withValues(alpha: 0.8)
                      : Colors.orange.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _postureMessage!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: _manualAddRep,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Add Rep',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _finishWorkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCCFF00),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text('Finish Workout'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Positioned(
      top: 80,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }
}
