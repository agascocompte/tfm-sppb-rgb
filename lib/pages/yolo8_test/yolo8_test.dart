import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sppb_rgb/models/polygon_painter.dart';
import 'package:sppb_rgb/pages/yolo8_test/bloc/yolo8_test_bloc.dart';
import 'package:sppb_rgb/widgets/camera_view/bloc/camera_view_bloc.dart';
import 'package:sppb_rgb/widgets/camera_view/camera_view.dart';

class Yolo8TestPage extends StatelessWidget {
  const Yolo8TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return BlocListener<CameraViewBloc, CameraViewState>(
      listener: (context, state) async {
        if (state is PictureCaptured) {
          context.read<Yolo8TestBloc>().add(ProcessImage(image: state.picture));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("YOLOv8 Segmentation"),
        ),
        body: BlocBuilder<Yolo8TestBloc, Yolo8TestState>(
            builder: (context, state) {
          return ((state.stateData.segmentator?.isLoaded ?? false) &&
                  (state.stateData.classifier?.isLoaded ?? false))
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    CameraView(
                      onCapture: () =>
                          context.read<CameraViewBloc>().add(TakePicture()),
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
      Size screen, Yolo8TestState state) {
    if (state.stateData.segmentatorResults.isEmpty ||
        state.stateData.capturedImage == null) return [];

    int imageWidth = state.stateData.imageWidth;
    int imageHeight = state.stateData.imageHeight;

    double factorX = screen.width / (imageWidth);
    double imgRatio = imageWidth / imageHeight;
    double newWidth = imageWidth * factorX;
    double newHeight = newWidth / imgRatio;
    double factorY = newHeight / (imageHeight);

    double pady = (screen.height - newHeight - 80) / 3;

    return state.stateData.segmentatorResults.map((result) {
      return RepaintBoundary(
        key: state.stateData.previewContainer,
        child: Stack(
          children: [
            Positioned(
              left: result["box"][1] * factorX,
              top: result["box"][0] * factorY + pady,
              width: (result["box"][3] - result["box"][1]) * factorX,
              height: (result["box"][2] - result["box"][0]) * factorY,
              child: Container(
                color: Colors.black,
              ),
            ),
            Positioned(
                left: result["box"][1] * factorX,
                top: result["box"][0] * factorY + pady,
                width: (result["box"][3] - result["box"][1]) * factorX,
                height: (result["box"][2] - result["box"][0]) * factorY,
                child: CustomPaint(
                  painter: PolygonPainter(
                      points: (result["polygons"] as List<dynamic>).map((e) {
                        Map<String, double> xy = Map<String, double>.from(e);
                        xy['x'] = (xy['x'] as double) * factorX;
                        xy['y'] = (xy['y'] as double) * factorY;
                        return xy;
                      }).toList(),
                      offset: (result["box"][3] - result["box"][1]) * factorX),
                )),
          ],
        ),
      );
    }).toList();
  }
}
