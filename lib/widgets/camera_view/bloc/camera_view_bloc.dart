import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

part 'camera_view_event.dart';
part 'camera_view_state.dart';

@injectable
class CameraViewBloc extends Bloc<CameraViewEvent, CameraViewState> {
  CameraViewBloc() : super(CameraViewInitial()) {
    on<InitializeCameras>(_initCameras);
    on<SwitchCamera>(_switchCamera);
    on<BeginImageCapture>(_beginImageCapture);
    on<TakePicture>(_takePicture);
  }

  FutureOr<void> _initCameras(
      InitializeCameras event, Emitter<CameraViewState> emit) async {
    List<CameraDescription> cameras = await availableCameras();
    CameraController cameraController =
        CameraController(cameras[0], ResolutionPreset.high);
    await cameraController.initialize();
    emit(CamerasInitialized(state.stateData
        .copyWith(cameras: cameras, cameraController: cameraController)));
  }

  FutureOr<void> _switchCamera(
      SwitchCamera event, Emitter<CameraViewState> emit) async {
    bool isRearCamera = !state.stateData.isRearCamera;
    state.stateData.cameraController?.setDescription(isRearCamera
        ? state.stateData.cameras![0]
        : state.stateData.cameras![1]);
    emit(CameraSwitched(state.stateData.copyWith(isRearCamera: isRearCamera)));
  }

  FutureOr<void> _beginImageCapture(
      BeginImageCapture event, Emitter<CameraViewState> emit) async {
    Duration captureDuration = Duration(seconds: event.capturingTime);
    const captureInterval = Duration(milliseconds: 50);

    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      emit(CameraError(state.stateData,
          error: "Error: external storage directory is not available"));
      return;
    }

    final label = event.label;
    final controller = state.stateData.cameraController;

    if (controller != null && controller.value.isInitialized) {
      final labelDirectory = Directory('${directory.path}/$label');
      if (!await labelDirectory.exists()) {
        await labelDirectory.create(recursive: true);
      }
      final endTime = DateTime.now().add(captureDuration);
      int imagesCaptured = 0;
      while (DateTime.now().isBefore(endTime)) {
        try {
          final image = await controller.takePicture();
          final String timestamp =
              DateTime.now().millisecondsSinceEpoch.toString();
          final String imagePath = '${labelDirectory.path}/$timestamp.jpg';

          final File imageFile = File(imagePath);
          await image.saveTo(imageFile.path);
          await Future.delayed(captureInterval);
          imagesCaptured++;
        } catch (e) {
          emit(
              CameraError(state.stateData, error: "Error capturing image: $e"));
        }
      }
      emit(GatheringImagesCompleted(state.stateData,
          msg: "Total images gathered: $imagesCaptured"));
    } else {
      emit(CameraError(state.stateData,
          error: "Error: camera is not initialized"));
    }
  }

  FutureOr<void> _takePicture(
      TakePicture event, Emitter<CameraViewState> emit) async {
    XFile picture = await state.stateData.cameraController!.takePicture();
    emit(PictureCaptured(state.stateData, picture: picture));
  }
}
