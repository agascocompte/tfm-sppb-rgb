import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'camera_view_event.dart';
part 'camera_view_state.dart';

@injectable
class CameraViewBloc extends Bloc<CameraViewEvent, CameraViewState> {
  CameraViewBloc() : super(CameraViewInitial()) {
    on<InitializeCameras>(_initCameras);
    on<SwitchCamera>(_switchCamera);
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
  }
}
