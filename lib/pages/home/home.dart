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
              onPressed: () {},
              child: const Text('Gait speed'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Get up'),
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
