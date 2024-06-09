part of 'camera_view_bloc.dart';

abstract class CameraViewEvent {}

class InitializeCameras extends CameraViewEvent {}

class SwitchCamera extends CameraViewEvent {}
