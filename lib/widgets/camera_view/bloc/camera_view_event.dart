part of 'camera_view_bloc.dart';

abstract class CameraViewEvent {}

class InitializeCameras extends CameraViewEvent {}

class SwitchCamera extends CameraViewEvent {}

class BeginImageCapture extends CameraViewEvent {
  String label;
  BeginImageCapture({required this.label});
}
