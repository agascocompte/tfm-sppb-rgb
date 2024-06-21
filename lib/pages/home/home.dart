import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sppb_rgb/router/router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SPPB Tests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.label_outline),
            onPressed: () {
              context.push(AppRouter.gatherImageRoute);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => context.push(AppRouter.testYolo8Seg),
              child: const Text('Test YOLO8 Segmentation'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Test YOLO8 Detector'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Test No YOLO'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Tandem'),
            ),
          ],
        ),
      ),
    );
  }
}
