import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sppb_rgb/pages/yolo8_det_test.dart/bloc/yolo8_det_test_bloc.dart';
import 'package:sppb_rgb/widgets/camera_view/bloc/camera_view_bloc.dart';
import 'package:sppb_rgb/widgets/camera_view/camera_view.dart';

class Yolo8DetTestPage extends StatelessWidget {
  const Yolo8DetTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return BlocConsumer<CameraViewBloc, CameraViewState>(
      listener: (context, state) async {
        if (state is PictureCaptured) {
          context
              .read<CameraViewBloc>()
              .add(UpdateIsImageProcessing(isImageProcessing: true));
          context
              .read<Yolo8DetTestBloc>()
              .add(ProcessImage(image: state.picture, size: size));
        }
      },
      builder: (context, cameraState) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Detection example"),
          ),
          body: BlocConsumer<Yolo8DetTestBloc, Yolo8DetTestState>(
              listener: (context, state) {
            if (state is PredictionSuccess || state is DetectionFailed) {
              context
                  .read<CameraViewBloc>()
                  .add(UpdateIsImageProcessing(isImageProcessing: false));
            }
          }, builder: (context, state) {
            return ((state.stateData.detector?.isLoaded ?? false) &&
                    (state.stateData.classifier?.isLoaded ?? false))
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      CameraView(
                        onCapture: () => !cameraState.stateData.isStreaming
                            ? context
                                .read<CameraViewBloc>()
                                .add(BeginImageStreaming())
                            : context
                                .read<CameraViewBloc>()
                                .add(StopImageStreaming()),
                      ),
                      Positioned(
                        top: 20,
                        left: 20,
                        child: Container(
                          height: 100,
                          width: 360,
                          color: Colors.black.withOpacity(0.5),
                          child: Center(
                            child: Text(
                              state.stateData.label,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: Text("Models not loaded, waiting for them"),
                  );
          }),
        );
      },
    );
  }
}
