part of 'camera_view_bloc.dart';

class CameraViewStateData {
  List<CameraDescription>? cameras;
  CameraController? cameraController;
  bool isRearCamera;
  bool isProcessingImage;

  CameraViewStateData({
    this.cameras,
    this.cameraController,
    this.isRearCamera = true,
    this.isProcessingImage = false,
  });

  CameraViewStateData copyWith({
    List<CameraDescription>? cameras,
    CameraController? cameraController,
    bool? isRearCamera,
    bool? isProcessingImage,
  }) {
    return CameraViewStateData(
      cameras: cameras ?? this.cameras,
      cameraController: cameraController ?? this.cameraController,
      isRearCamera: isRearCamera ?? this.isRearCamera,
      isProcessingImage: isProcessingImage ?? this.isProcessingImage,
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

class CameraSwitched extends CameraViewState {
  CameraSwitched(CameraViewStateData stateData) : super(stateData: stateData);
}

class CameraError extends CameraViewState {
  final String error;
  CameraError(CameraViewStateData stateData, {required this.error})
      : super(stateData: stateData);
}

class GatheringImagesCompleted extends CameraViewState {
  final String msg;
  GatheringImagesCompleted(CameraViewStateData stateData, {required this.msg})
      : super(stateData: stateData);
}

class PictureCaptured extends CameraViewState {
  final CameraImage picture;
  PictureCaptured(CameraViewStateData stateData, {required this.picture})
      : super(stateData: stateData);
}

class IsImageProcessingUpdated extends CameraViewState {
  IsImageProcessingUpdated(CameraViewStateData stateData)
      : super(stateData: stateData);
}
