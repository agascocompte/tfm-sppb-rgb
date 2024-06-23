part of 'yolo8_det_test_bloc.dart';

abstract class Yolo8DetTestEvent {}

class LoadDetModels extends Yolo8DetTestEvent {}

class ProcessImage extends Yolo8DetTestEvent {
  final CameraImage image;
  final Size size;
  ProcessImage({required this.image, required this.size});
}

class ProcessDetectedImage extends Yolo8DetTestEvent {
  final Size size;
  ProcessDetectedImage({required this.size});
}
