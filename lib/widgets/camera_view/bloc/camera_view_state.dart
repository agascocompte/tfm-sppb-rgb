part of 'camera_view_bloc.dart';

class CameraViewStateData {
  List<CameraDescription>? cameras;
  CameraController? cameraController;
  bool isRearCamera;

  CameraViewStateData({
    this.cameras,
    this.cameraController,
    this.isRearCamera = true,
  });

  CameraViewStateData copyWith({
    List<CameraDescription>? cameras,
    CameraController? cameraController,
    bool? isRearCamera,
  }) {
    return CameraViewStateData(
      cameras: cameras ?? this.cameras,
      cameraController: cameraController ?? this.cameraController,
      isRearCamera: isRearCamera ?? this.isRearCamera,
    );
  }
}

abstract class CameraViewState {
  final CameraViewStateData stateData;

  CameraViewState({required this.stateData});
}

class CameraViewInitial extends CameraViewState {
  CameraViewInitial() : super(stateData: CameraViewStateData());
}

class CamerasInitialized extends CameraViewState {
  CamerasInitialized(CameraViewStateData stateData)
      : super(stateData: stateData);
}
