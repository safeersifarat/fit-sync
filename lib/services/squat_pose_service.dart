import 'dart:math' as math;
import 'dart:ui' show Size;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class SquatPoseResult {
  const SquatPoseResult({
    required this.pose,
    required this.depthAngle,
    required this.backAngle,
    required this.isGoodDepth,
    required this.isGoodPosture,
    this.repPhase,
    this.message,
    required this.imageSize,
  });

  /// The raw pose object so the UI can draw the skeleton.
  final Pose pose;

  /// Angle of the knee (Hip - Knee - Ankle)
  final double depthAngle;

  /// Angle of the back (Shoulder - Hip - Knee)
  final double backAngle;

  /// Whether the user has gone low enough (depthAngle <= 90 is a full squat,
  /// but we'll use < 110 as a generous threshold for "good depth").
  final bool isGoodDepth;

  /// Whether back is straight enough.
  final bool isGoodPosture;

  /// 'standing' | 'squatting'
  final String? repPhase;

  /// Feedback message
  final String? message;

  /// The size of the InputImage that derived this pose.
  final Size imageSize;
}

class SquatPoseService {
  SquatPoseService() {
    _detector = PoseDetector(
      options: PoseDetectorOptions(
        mode: PoseDetectionMode.stream,
        model: PoseDetectionModel.accurate,
      ),
    );
  }

  late final PoseDetector _detector;

  InputImage? _imageFromCameraImage(
    CameraImage image,
    CameraLensDirection lensDirection,
  ) {
    if (image.format.group != ImageFormatGroup.yuv420) return null;

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

  Future<SquatPoseResult?> processFrame(
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

      // Extract left and right leg landmarks
      final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
      final leftHip = landmarks[PoseLandmarkType.leftHip];
      final leftKnee = landmarks[PoseLandmarkType.leftKnee];
      final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];

      final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
      final rightHip = landmarks[PoseLandmarkType.rightHip];
      final rightKnee = landmarks[PoseLandmarkType.rightKnee];
      final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];

      // Find which side is more visible (higher average likelihood)
      double leftLikelihood =
          ((leftShoulder?.likelihood ?? 0) +
              (leftHip?.likelihood ?? 0) +
              (leftKnee?.likelihood ?? 0) +
              (leftAnkle?.likelihood ?? 0)) /
          4;

      double rightLikelihood =
          ((rightShoulder?.likelihood ?? 0) +
              (rightHip?.likelihood ?? 0) +
              (rightKnee?.likelihood ?? 0) +
              (rightAnkle?.likelihood ?? 0)) /
          4;

      // Determine which landmarks to use for calculation
      PoseLandmark? shoulder;
      PoseLandmark? hip;
      PoseLandmark? knee;
      PoseLandmark? ankle;

      if (leftLikelihood > rightLikelihood && leftLikelihood > 0.2) {
        shoulder = leftShoulder;
        hip = leftHip;
        knee = leftKnee;
        ankle = leftAnkle;
      } else if (rightLikelihood > leftLikelihood && rightLikelihood > 0.2) {
        shoulder = rightShoulder;
        hip = rightHip;
        knee = rightKnee;
        ankle = rightAnkle;
      }

      // Default values if we can't find a good leg
      double depthAngle = 180.0;
      double backAngle = 180.0;
      bool isGoodDepth = true;
      bool isGoodPosture = true;
      String? repPhase = 'standing';
      String? message;

      if (shoulder != null && hip != null && knee != null && ankle != null) {
        depthAngle = _angle(hip.x, hip.y, knee.x, knee.y, ankle.x, ankle.y);

        backAngle = _angle(
          shoulder.x,
          shoulder.y,
          hip.x,
          hip.y,
          knee.x,
          knee.y,
        );

        isGoodDepth = depthAngle < 110;
        isGoodPosture = backAngle > 50;

        if (depthAngle > 150)
          repPhase = 'standing';
        else if (depthAngle < 100)
          repPhase = 'squatting';
        else
          repPhase = 'transitioning';

        if (!isGoodPosture && repPhase == 'squatting') {
          message = 'Keep your chest up!';
        } else if (!isGoodDepth &&
            depthAngle > 110 &&
            depthAngle < 140 &&
            repPhase != 'standing') {
          message = 'Go lower!';
        } else if (repPhase == 'standing') {
          message = 'Ready. Lower slowly.';
        } else if (repPhase == 'squatting') {
          message = 'Good depth. Push up!';
        }
      } else {
        message = 'Please step back into full view';
      }

      return SquatPoseResult(
        pose: pose,
        depthAngle: depthAngle,
        backAngle: backAngle,
        isGoodDepth: isGoodDepth,
        isGoodPosture: isGoodPosture,
        repPhase: repPhase,
        message: message,
        imageSize: inputImage.metadata!.size,
      );
    } catch (e) {
      if (kDebugMode) print('Squat error: $e');
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
    final a = (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2);
    final b = (x3 - x2) * (x3 - x2) + (y3 - y2) * (y3 - y2);
    final c = (x1 - x3) * (x1 - x3) + (y1 - y3) * (y1 - y3);
    final denom = 2 * math.sqrt((a * b).clamp(1e-6, double.infinity));
    final cosAngle = ((a + b - c) / denom).clamp(-1.0, 1.0);
    return (math.pi - math.acos(cosAngle)) * 180 / math.pi;
  }

  void dispose() {
    _detector.close();
  }
}
