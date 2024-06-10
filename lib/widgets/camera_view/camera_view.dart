import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sppb_rgb/router/router.dart';
import 'package:sppb_rgb/widgets/app_scaffold_messenger.dart';
import 'package:sppb_rgb/widgets/camera_view/bloc/camera_view_bloc.dart';

class CameraView extends StatelessWidget {
  final Function() onCapture;
  final bool viewCapturedImages;

  const CameraView(
      {super.key, required this.onCapture, this.viewCapturedImages = false});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CameraViewBloc, CameraViewState>(
        listener: (context, state) {
      if (state is CameraError) {
        AppScaffoldMessenger.showWarningScaffold(context, state.error);
      } else if (state is GatheringImagesCompleted) {
        AppScaffoldMessenger.showSuccessScaffold(context, state.msg);
      }
    }, builder: (context, state) {
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
                if (viewCapturedImages)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: FloatingActionButton(
                      heroTag: 'viewCapturedImages',
                      onPressed: () =>
                          context.push(AppRouter.viewCapturedImages),
                      child: const Icon(Icons.image_outlined),
                    ),
                  ),
              ],
            )
          : const Center(child: Text("Cámara no inicializada"));
    });
  }
}
