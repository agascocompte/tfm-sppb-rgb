import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SPPB Tests'),
        actions: [
          IconButton(
            icon: Icon(Icons.camera),
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => CameraPage()),
              // );
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
              child: Text('Gait speed'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text('Get up'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text('Feet together'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text('Semi-tandem'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text('Tandem'),
            ),
          ],
        ),
      ),
    );
  }
}
