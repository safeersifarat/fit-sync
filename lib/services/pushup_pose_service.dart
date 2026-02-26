import 'dart:math' as math;
import 'dart:ui' show Size;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PushupPoseResult {
  const PushupPoseResult({
    required this.elbowAngle,
    required this.bodyAngle,
    required this.isGoodPosture,
    this.repPhase,
    this.message,
    this.pose,
    this.imageSize,
  });

  final double elbowAngle;
  final double bodyAngle;
  final bool isGoodPosture;
  final String? repPhase;
  final String? message;
  final Pose? pose;
  final Size? imageSize;
}

class PushupPoseService {
  PushupPoseService() {
    _detector = PoseDetector(
      options: PoseDetectorOptions(
        mode: PoseDetectionMode.stream,
        model: PoseDetectionModel.accurate,
      ),
    );
    _initTts();
  }

  late final PoseDetector _detector;
  final FlutterTts _flutterTts = FlutterTts();

  DateTime _lastSpokenTime = DateTime.now();

  bool isMuted = false;

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  InputImage? _imageFromCameraImage(
    CameraImage image,
    CameraLensDirection lensDirection,
  ) {
    if (image.format.group != ImageFormatGroup.yuv420) {
      return null;
    }

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

  void _speakFeedback(String message) async {
    if (isMuted) return;
    final now = DateTime.now();
    if (now.difference(_lastSpokenTime).inSeconds >= 2) {
      _lastSpokenTime = now;
      await _flutterTts.speak(message);
    }
  }

  void speak(String text) {
    if (isMuted) return;
    _flutterTts.speak(text);
  }

  Future<PushupPoseResult?> processFrame(
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
      final leftHip = landmarks[PoseLandmarkType.leftHip];
      final leftKnee = landmarks[PoseLandmarkType.leftKnee];
      final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];

      final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
      final rightElbow = landmarks[PoseLandmarkType.rightElbow];
      final rightWrist = landmarks[PoseLandmarkType.rightWrist];
      final rightHip = landmarks[PoseLandmarkType.rightHip];
      final rightKnee = landmarks[PoseLandmarkType.rightKnee];
      final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];

      double elbowAngle = 0;
      double bodyAngle = 0;

      // Better visibility logic could be added, here using right side as priority if available
      if (rightShoulder != null &&
          rightElbow != null &&
          rightWrist != null &&
          rightHip != null &&
          rightKnee != null &&
          rightAnkle != null) {
        elbowAngle = _angle(
          rightShoulder.x,
          rightShoulder.y,
          rightElbow.x,
          rightElbow.y,
          rightWrist.x,
          rightWrist.y,
        );
        bodyAngle = _angle(
          rightShoulder.x,
          rightShoulder.y,
          rightHip.x,
          rightHip.y,
          rightKnee.x,
          rightKnee.y, // using knee or ankle
        );
      } else if (leftShoulder != null &&
          leftElbow != null &&
          leftWrist != null &&
          leftHip != null &&
          leftKnee != null &&
          leftAnkle != null) {
        elbowAngle = _angle(
          leftShoulder.x,
          leftShoulder.y,
          leftElbow.x,
          leftElbow.y,
          leftWrist.x,
          leftWrist.y,
        );
        bodyAngle = _angle(
          leftShoulder.x,
          leftShoulder.y,
          leftHip.x,
          leftHip.y,
          leftKnee.x,
          leftKnee.y, // using knee or ankle
        );
      } else {
        return null;
      }

      // Check for straight back (ideally > 140 degrees)
      bool isBackStraight = bodyAngle >= 140;
      bool isGoodPosture = isBackStraight;

      String? repPhase;
      // Pushup extended arm > 140 degrees
      if (elbowAngle > 140) repPhase = 'extended';
      // Pushup flexed arm < 110 degrees
      if (elbowAngle < 110) repPhase = 'flexed';

      String? message;
      if (!isBackStraight) {
        message = 'Keep your back straight and hips aligned.';
        _speakFeedback(message);
      } else if (repPhase == 'flexed' && elbowAngle > 110) {
        message = 'Go lower, chest to the floor.';
        _speakFeedback(message);
      } else if (repPhase == 'extended' && elbowAngle < 140) {
        message = 'Push all the way up, extending your arms fully.';
        _speakFeedback(message);
      }

      // Calculate image size for drawing
      final rotation = _rotationFromLensDirection(lensDirection);
      Size imageSize;
      if (rotation == InputImageRotation.rotation90deg ||
          rotation == InputImageRotation.rotation270deg) {
        imageSize = Size(image.height.toDouble(), image.width.toDouble());
      } else {
        imageSize = Size(image.width.toDouble(), image.height.toDouble());
      }

      return PushupPoseResult(
        elbowAngle: elbowAngle,
        bodyAngle: bodyAngle,
        isGoodPosture: isGoodPosture,
        repPhase: repPhase,
        message: message ?? (isGoodPosture ? 'Perfect posture!' : null),
        pose: pose,
        imageSize: imageSize,
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
    if (denom == 0) return 0;
    final cosAngle = ((a + b - c) / denom).clamp(-1.0, 1.0);
    return math.pi - math.acos(cosAngle);
  }

  void dispose() {
    _detector.close();
    _flutterTts.stop();
  }
}
