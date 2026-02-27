import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../services/squat_pose_service.dart';
import 'workout_thank_you_screen.dart';

/// Full-screen squat workout with AI feedback and posture line rendering
class SquatWorkoutScreen extends StatefulWidget {
  const SquatWorkoutScreen({super.key, required this.title, this.targetReps});

  final String title;
  final int? targetReps;

  @override
  State<SquatWorkoutScreen> createState() => _SquatWorkoutScreenState();
}

class _SquatWorkoutScreenState extends State<SquatWorkoutScreen> {
  CameraController? _camera;
  final _poseService = SquatPoseService();
  bool _isInitialized = false;
  String? _error;

  int _repCount = 0;
  String? _postureMessage;
  bool _isGoodPostfix = true;
  String _repPhase = 'standing'; // standing | squatting | transitioning
  bool _hasReachedSquatDepth = false; // State machine flag for reps
  DateTime _startTime = DateTime.now();
  bool _isProcessing = false;

  // For drawing
  Pose? _currentPose;
  Size? _imageSize;
  CameraLensDirection _cameraLensDirection = CameraLensDirection.front;

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
      _cameraLensDirection = camera.lensDirection;

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
        } else {
          // No pose found, clear drawings
          setState(() {
            _currentPose = null;
          });
        }
      } catch (_) {}
      _isProcessing = false;
    });
  }

  void _updateRepAndPosture(SquatPoseResult result) {
    setState(() {
      _currentPose = result.pose;
      _imageSize = result.imageSize;

      _postureMessage = result.message;
      _isGoodPostfix = result.isGoodPosture && result.isGoodDepth;

      final phase = result.repPhase ?? _repPhase;

      // Rep completed when returning to 'standing' after having been 'squatting'
      // Since there is a 'transitioning' phase in between, we track if we hit 'squatting' recently.
      if (phase == 'standing' && _repPhase == 'transitioning') {
        // Usually, if we were transitioning on our way up, it means we completed a squat.
        // However, let's make it simpler: we will just track if we hit 'squatting'.
      }

      // To make it robust:
      // If the current phase is 'squatting', set a variable flag holding state
      // When we hit 'standing' and the flag is true, count the rep and reset flag.

      if (phase == 'squatting') {
        _hasReachedSquatDepth = true;
      } else if (phase == 'standing' && _hasReachedSquatDepth) {
        _repCount++;
        _hasReachedSquatDepth = false; // Reset for next rep
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
            _buildBodyLinesOverlay(),
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

  // Uses a CustomPainter to draw lines directly over the camera feed.
  Widget _buildBodyLinesOverlay() {
    if (_currentPose == null || _imageSize == null) return const SizedBox();

    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: SquatPainter(
            pose: _currentPose!,
            imageSize: _imageSize!,
            cameraLensDirection: _cameraLensDirection,
            isGoodDepth: _isGoodPostfix,
          ),
        );
      },
    );
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
                  color: _isGoodPostfix
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

class SquatPainter extends CustomPainter {
  SquatPainter({
    required this.pose,
    required this.imageSize,
    required this.cameraLensDirection,
    required this.isGoodDepth,
  });

  final Pose pose;
  final Size imageSize;
  final CameraLensDirection cameraLensDirection;
  final bool isGoodDepth;

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    final landmarks = pose.landmarks;

    // Helper to translate ML Kit absolute bounds into screen coordinate bounds.
    Offset scale(PoseLandmark? lm) {
      if (lm == null) return Offset.zero;

      final double renderX;
      final double renderY;

      // When the camera is front, it's typically mirrored.
      if (cameraLensDirection == CameraLensDirection.front) {
        renderX = size.width - (lm.x / imageSize.width) * size.width;
      } else {
        renderX = (lm.x / imageSize.width) * size.width;
      }

      renderY = (lm.y / imageSize.height) * size.height;

      return Offset(renderX, renderY);
    }

    // Helper to draw a line between two points if both are valid
    void drawConnection(
      PoseLandmarkType type1,
      PoseLandmarkType type2,
      Paint linePaint,
    ) {
      final p1 = scale(landmarks[type1]);
      final p2 = scale(landmarks[type2]);
      if (p1 != Offset.zero && p2 != Offset.zero) {
        canvas.drawLine(p1, p2, linePaint);
      }
    }

    // Helper to draw a dot for a specific landmark
    void drawLandmark(PoseLandmarkType type) {
      final p = scale(landmarks[type]);
      if (p != Offset.zero) {
        canvas.drawCircle(p, 6, dotPaint);
      }
    }

    // Colors
    final leftPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = isGoodDepth ? Colors.greenAccent : Colors.orangeAccent;
    final rightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = isGoodDepth ? Colors.greenAccent : Colors.orangeAccent;
    final centerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.white70;

    // Draw lines (Connections)
    // Left arm
    drawConnection(
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.leftElbow,
      leftPaint,
    );
    drawConnection(
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.leftWrist,
      leftPaint,
    );

    // Right arm
    drawConnection(
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.rightElbow,
      rightPaint,
    );
    drawConnection(
      PoseLandmarkType.rightElbow,
      PoseLandmarkType.rightWrist,
      rightPaint,
    );

    // Torso
    drawConnection(
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
      centerPaint,
    );
    drawConnection(
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.leftHip,
      leftPaint,
    );
    drawConnection(
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.rightHip,
      rightPaint,
    );
    drawConnection(
      PoseLandmarkType.leftHip,
      PoseLandmarkType.rightHip,
      centerPaint,
    );

    // Left leg
    drawConnection(
      PoseLandmarkType.leftHip,
      PoseLandmarkType.leftKnee,
      leftPaint,
    );
    drawConnection(
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.leftAnkle,
      leftPaint,
    );

    // Right leg
    drawConnection(
      PoseLandmarkType.rightHip,
      PoseLandmarkType.rightKnee,
      rightPaint,
    );
    drawConnection(
      PoseLandmarkType.rightKnee,
      PoseLandmarkType.rightAnkle,
      rightPaint,
    );

    // Draw all points
    for (final type in PoseLandmarkType.values) {
      // Exclude facial landmarks for cleaner view if desired, or include them:
      if (type.index > PoseLandmarkType.rightMouth.index) {
        drawLandmark(type);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SquatPainter oldDelegate) {
    return oldDelegate.pose != pose ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.isGoodDepth != isGoodDepth;
  }
}
