import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sppb_rgb/models/polygon_painter.dart';
import 'package:sppb_rgb/pages/yolo8_seg_test/bloc/yolo8_seg_test_bloc.dart';
import 'package:sppb_rgb/widgets/camera_view/bloc/camera_view_bloc.dart';
import 'package:sppb_rgb/widgets/camera_view/camera_view.dart';

class Yolo8SegTestPage extends StatelessWidget {
  const Yolo8SegTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return BlocListener<CameraViewBloc, CameraViewState>(
      listener: (context, state) async {
        if (state is PictureCaptured) {
          context
              .read<CameraViewBloc>()
              .add(UpdateIsImageProcessing(isImageProcessing: true));
          context
              .read<Yolo8SegTestBloc>()
              .add(ProcessImage(image: state.picture));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("YOLOv8 Segmentation"),
        ),
        body: BlocConsumer<Yolo8SegTestBloc, Yolo8SegTestState>(
            listener: (context, state) {
          if (state is PredictionSuccess || state is SegmentationFailed) {
            context
                .read<CameraViewBloc>()
                .add(UpdateIsImageProcessing(isImageProcessing: false));
          }
        }, builder: (context, state) {
          return ((state.stateData.segmentator?.isLoaded ?? false) &&
                  (state.stateData.classifier?.isLoaded ?? false))
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    CameraView(
                      onCapture: () => context
                          .read<CameraViewBloc>()
                          .add(BeginImageStreaming()),
                    ),
                    ...displayBoxesAroundRecognizedObjects(size, state),
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
      ),
    );
  }

  List<Widget> displayBoxesAroundRecognizedObjects(
      Size screen, Yolo8SegTestState state) {
    if (state.stateData.segmentatorResults.isEmpty ||
        state.stateData.capturedImage == null) return [];

    int imageWidth = state.stateData.imageWidth;
    int imageHeight = state.stateData.imageHeight;

    double factorX = screen.width / (imageWidth);
    double imgRatio = imageWidth / imageHeight;
    double newWidth = imageWidth * factorX;
    double newHeight = newWidth / imgRatio;
    double factorY = newHeight / (imageHeight);

    return state.stateData.segmentatorResults.map((result) {
      return result["box"] != null
          ? RepaintBoundary(
              key: state.stateData.previewContainer,
              child: Stack(
                children: [
                  Positioned(
                    left: result["box"][0] * factorX,
                    top: result["box"][1] * factorY,
                    width: (result["box"][2] - result["box"][0]) * factorX,
                    height: (result["box"][3] - result["box"][1]) * factorY,
                    child: Container(
                      color: Colors.black,
                    ),
                  ),
                  Positioned(
                      left: result["box"][0] * factorX,
                      top: result["box"][1] * factorY,
                      width: (result["box"][2] - result["box"][0]) * factorX,
                      height: (result["box"][3] - result["box"][1]) * factorY,
                      child: CustomPaint(
                        painter: PolygonPainter(
                          points:
                              (result["polygons"] as List<dynamic>).map((e) {
                            Map<String, double> xy =
                                Map<String, double>.from(e);
                            xy['x'] = (xy['x'] as double) * factorX;
                            xy['y'] = (xy['y'] as double) * factorY;
                            return xy;
                          }).toList(),
                        ),
                      )),
                ],
              ),
            )
          : Container();
    }).toList();
  }
}
