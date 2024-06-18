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
              onPressed: () => context.push(AppRouter.testYolo8),
              child: const Text('Test YOLO8'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Feet together'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Semi-tandem'),
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
