import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PosePainter extends CustomPainter {
  PosePainter(this.pose, this.imageSize, this.lensDirection);

  final Pose pose;
  final Size imageSize;
  final CameraLensDirection lensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    if (imageSize.width == 0 || imageSize.height == 0) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.greenAccent;

    // ML Kit processes image from camera frames. Camera frames for portrait are usually Rotated.
    // So the ML Kit actually operates on the rotated bounds.
    // Or we simply map input image x,y to the canvas.
    // But since Mobile cameras give YUV in raw format (landscape usually), 
    // the width and height might be swapped compared to the screen.

    // Calculate scale and flip based on orientation and lens direction
    final double scaleX = size.width / imageSize.width;
    final double scaleY = size.height / imageSize.height;

    double translateX(double x) {
      if (lensDirection == CameraLensDirection.front) {
        return size.width - (x * scaleX);
      }
      return x * scaleX;
    }

    double translateY(double y) {
      return y * scaleY;
    }

    void paintLine(
        PoseLandmarkType type1, PoseLandmarkType type2, Paint paintType) {
      final PoseLandmark? joint1 = pose.landmarks[type1];
      final PoseLandmark? joint2 = pose.landmarks[type2];
      if (joint1 != null && joint2 != null) {
        // Draw only if likelihood is high enough (ML Kit doesn't provide likelihood though)
        canvas.drawLine(
          Offset(translateX(joint1.x), translateY(joint1.y)),
          Offset(translateX(joint2.x), translateY(joint2.y)),
          paintType,
        );
      }
    }

    // Draw lines
    paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder, paint);
    paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, paint);
    paintLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, paint);
    paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, paint);
    paintLine(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, paint);
    paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, paint);
    paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, paint);
    paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip, paint);
    paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, paint);
    paintLine(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, paint);
    paintLine(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, paint);
    paintLine(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, paint);

    // Draw dots
    for (final landmark in pose.landmarks.values) {
      canvas.drawCircle(
        Offset(translateX(landmark.x), translateY(landmark.y)),
        4,
        Paint()..color = Colors.redAccent,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.pose != pose;
  }
}
