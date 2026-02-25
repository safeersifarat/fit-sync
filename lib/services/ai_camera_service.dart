import 'dart:async';

import 'package:camera/camera.dart';

/// Simple wrapper around the camera package for the AI Scan UI.
/// This provides a CameraController and a mocked detection result.
class AiCameraService {
  CameraController? controller;

  Future<void> initialize() async {
    final cameras = await availableCameras();
    final camera = cameras.first;
    controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await controller!.initialize();
  }

  Future<DetectedFood> mockDetectFood() async {
    // In a real app this would call an ML model / backend.
    await Future.delayed(const Duration(seconds: 2));
    return const DetectedFood(name: 'Smoothie Bowl', calories: 250);
  }

  void dispose() {
    controller?.dispose();
  }
}

class DetectedFood {
  const DetectedFood({required this.name, required this.calories});

  final String name;
  final int calories;
}
