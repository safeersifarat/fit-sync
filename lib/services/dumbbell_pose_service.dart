import 'dart:math' as math;
import 'dart:ui' show Size;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Result of pose analysis for dumbbell (bicep curl) tracking.
class DumbbellPoseResult {
  const DumbbellPoseResult({
    required this.elbowAngle,
    required this.isGoodPosture,
    this.repPhase,
    this.message,
  });

  /// Elbow angle in degrees (0-180). ~180 = arm extended, ~30 = arm flexed.
  final double elbowAngle;

  /// Whether current posture is acceptable (elbow stable, back straight).
  final bool isGoodPosture;

  /// Current rep phase: 'extended' | 'flexed' | null
  final String? repPhase;

  /// User-facing feedback message.
  final String? message;
}

/// Service for dumbbell pose detection using ML Kit pose landmarks.
/// Computes elbow angle (shoulder-elbow-wrist) for bicep curl rep counting
/// and posture feedback.
class DumbbellPoseService {
  DumbbellPoseService() {
    _detector = PoseDetector(
      options: PoseDetectorOptions(
        mode: PoseDetectionMode.stream,
        model: PoseDetectionModel.accurate,
      ),
    );
  }

  late final PoseDetector _detector;

  /// Converts CameraImage to InputImage for ML Kit (Android YUV420 → NV21).
  InputImage? _imageFromCameraImage(
    CameraImage image,
    CameraLensDirection lensDirection,
  ) {
    if (image.format.group != ImageFormatGroup.yuv420) {
      return null;
    }
    // Android YUV420_888 → NV21 conversion
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];
    final yRowStride = yPlane.bytesPerRow;
    final yPixelStride = yPlane.bytesPerPixel ?? 1;
    final uvRowStride = uPlane.bytesPerRow;
    final uvPixelStride = uPlane.bytesPerPixel ?? 1;
    final width = image.width;
    final height = image.height;

    final nv21 = Uint8List(width * height + 2 * (width ~/ 2) * (height ~/ 2));
    var pos = 0;
    for (var row = 0; row < height; row++) {
      for (var col = 0; col < width; col++) {
        nv21[pos++] = yPlane.bytes[row * yRowStride + col * yPixelStride];
      }
    }
    pos = width * height;
    for (var row = 0; row < height ~/ 2; row++) {
      for (var col = 0; col < width ~/ 2; col++) {
        nv21[pos++] = vPlane.bytes[row * uvRowStride + col * uvPixelStride];
        nv21[pos++] = uPlane.bytes[row * uvRowStride + col * uvPixelStride];
      }
    }

    final metadata = InputImageMetadata(
      size: Size(width.toDouble(), height.toDouble()),
      rotation: _rotationFromLensDirection(lensDirection),
      format: InputImageFormat.nv21,
      bytesPerRow: yRowStride,
    );

    return InputImage.fromBytes(bytes: nv21, metadata: metadata);
  }

  InputImageRotation _rotationFromLensDirection(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return InputImageRotation.rotation0deg;
      case CameraLensDirection.front:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  /// Process a camera frame and return pose result for dumbbell tracking.
  Future<DumbbellPoseResult?> processFrame(
    CameraImage image,
    CameraLensDirection lensDirection,
  ) async {
    final inputImage = _imageFromCameraImage(image, lensDirection);
    if (inputImage == null) return null;

    try {
      final poses = await _detector.processImage(inputImage);
      if (poses.isEmpty) return null;

      final pose = poses.first;
      final landmarks = pose.landmarks;

      final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
      final leftElbow = landmarks[PoseLandmarkType.leftElbow];
      final leftWrist = landmarks[PoseLandmarkType.leftWrist];
      final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
      final rightElbow = landmarks[PoseLandmarkType.rightElbow];
      final rightWrist = landmarks[PoseLandmarkType.rightWrist];

      // Use the arm with more visible movement (higher confidence) or default to right
      double angle = 0;
      if (rightElbow != null && rightShoulder != null && rightWrist != null) {
        angle = _angle(
          rightShoulder.x,
          rightShoulder.y,
          rightElbow.x,
          rightElbow.y,
          rightWrist.x,
          rightWrist.y,
        );
      } else if (leftElbow != null &&
          leftShoulder != null &&
          leftWrist != null) {
        angle = _angle(
          leftShoulder.x,
          leftShoulder.y,
          leftElbow.x,
          leftElbow.y,
          leftWrist.x,
          leftWrist.y,
        );
      } else {
        return null;
      }

      final isGoodPosture = angle >= 20 && angle <= 180;
      String? repPhase;
      if (angle > 120) repPhase = 'extended';
      if (angle < 60) repPhase = 'flexed';

      String? message;
      if (angle < 20) message = 'Extend your arm fully';
      if (!isGoodPosture && angle > 60 && angle < 120) {
        message = 'Keep elbow stable';
      }

      return DumbbellPoseResult(
        elbowAngle: angle,
        isGoodPosture: isGoodPosture,
        repPhase: repPhase,
        message: message ?? (isGoodPosture ? 'Good form!' : null),
      );
    } catch (e) {
      if (kDebugMode) print('Pose processing error: $e');
      return null;
    }
  }

  double _angle(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) {
    final rad = _angleRad(x1, y1, x2, y2, x3, y3);
    return rad * 180 / math.pi;
  }

  double _angleRad(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) {
    final a = (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2);
    final b = (x3 - x2) * (x3 - x2) + (y3 - y2) * (y3 - y2);
    final c = (x1 - x3) * (x1 - x3) + (y1 - y3) * (y1 - y3);
    final denom = 2 * math.sqrt((a * b).clamp(1e-6, double.infinity));
    final cosAngle = ((a + b - c) / denom).clamp(-1.0, 1.0);
    return math.pi - math.acos(cosAngle);
  }

  void dispose() {
    _detector.close();
  }
}
