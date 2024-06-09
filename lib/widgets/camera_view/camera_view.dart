import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sppb_rgb/widgets/camera_view/bloc/camera_view_bloc.dart';

class CameraView extends StatelessWidget {
  final Function() onCapture;

  const CameraView({super.key, required this.onCapture});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CameraViewBloc, CameraViewState>(
        builder: (context, state) {
      return state.stateData.cameraController != null
          ? Stack(
              children: [
                CameraPreview(state.stateData.cameraController!),
                Positioned(
                  bottom: 16,
                  left: MediaQuery.of(context).size.width / 2 - 30,
                  child: FloatingActionButton(
                    heroTag: 'onCapture',
                    onPressed: onCapture,
                    child: const Icon(Icons.camera),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    heroTag: 'switchCamera',
                    onPressed: () =>
                        context.read<CameraViewBloc>().add(SwitchCamera()),
                    child: const Icon(Icons.switch_camera),
                  ),
                ),
              ],
            )
          : const Center(child: Text("Cámara no inicializada"));
    });
  }
}
