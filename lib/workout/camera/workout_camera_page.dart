import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../pose_detection/pose_detector_service.dart';
import 'package:flutter/foundation.dart';

class WorkoutCameraPage extends StatefulWidget {
  final String exerciseName;
  final int targetReps;

  const WorkoutCameraPage({
    super.key,
    required this.exerciseName,
    required this.targetReps,
  });

  @override
  State<WorkoutCameraPage> createState() => _WorkoutCameraPageState();
}

class _WorkoutCameraPageState extends State<WorkoutCameraPage> {
  CameraController? _cameraController;
  late PoseDetectorService _poseService;

  int reps = 0;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    _poseService = PoseDetectorService();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();

    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();

    _cameraController!.startImageStream(_processCameraImage);

    setState(() {});
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (isProcessing) return;

    isProcessing = true;

    try {
      final WriteBuffer allBytes = WriteBuffer();

      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }

      final bytes = allBytes.done().buffer.asUint8List();

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.yuv420,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );

      final poses = await _poseService.detectPose(inputImage);

      if (poses.isNotEmpty) {
        _handlePose(poses.first);
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    isProcessing = false;
  }

  void _handlePose(Pose pose) {
    // TEMP: just testing detection
    print("Pose detected with ${pose.landmarks.length} landmarks");
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _poseService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraPreview(_cameraController!),

          Positioned(
            top: 80,
            left: 20,
            child: Text(
              "Reps: $reps / ${widget.targetReps}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
