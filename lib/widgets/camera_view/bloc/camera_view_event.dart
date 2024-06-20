part of 'camera_view_bloc.dart';

abstract class CameraViewEvent {}

class InitializeCameras extends CameraViewEvent {}

class SwitchCamera extends CameraViewEvent {}

class BeginImageCapture extends CameraViewEvent {
  final String label;
  final int capturingTime;
  BeginImageCapture({required this.label, required this.capturingTime});
}

class TakePicture extends CameraViewEvent {}
