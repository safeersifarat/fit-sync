import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseDetectorService {
  final PoseDetector _poseDetector = PoseDetector(
    options: PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
    ),
  );

  Future<List<Pose>> detectPose(InputImage image) async {
    return await _poseDetector.processImage(image);
  }

  void dispose() {
    _poseDetector.close();
  }
}