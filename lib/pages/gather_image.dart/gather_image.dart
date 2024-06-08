import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class GatherImagePage extends StatefulWidget {
  const GatherImagePage({super.key});

  @override
  GatherImagePageState createState() => GatherImagePageState();
}

class GatherImagePageState extends State<GatherImagePage> {
  late List<CameraDescription> cameras;
  late CameraController controller;
  bool isRearCamera = true;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.high);
    await controller.initialize();
    setState(() {});
  }

  void switchCamera() {
    if (controller != null) {
      controller.dispose();
    }
    isRearCamera = !isRearCamera;
    controller = CameraController(
        isRearCamera ? cameras[0] : cameras[1], ResolutionPreset.high);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera'),
        actions: [
          IconButton(
            icon: Icon(Icons.switch_camera),
            onPressed: switchCamera,
          ),
        ],
      ),
      body: Stack(
        children: [
          CameraPreview(controller),
          Positioned(
            bottom: 16,
            left: 16,
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Aquí puedes añadir funcionalidad para etiquetar las imágenes
                  },
                  child: Text('Etiqueta 1'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    // Aquí puedes añadir funcionalidad para etiquetar las imágenes
                  },
                  child: Text('Etiqueta 2'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
