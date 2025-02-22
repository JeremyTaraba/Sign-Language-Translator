import 'package:flutter/material.dart';
import 'package:sign_language_trasnlator2/utility/bottom_nav.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center(child: Text("camera")),
        ],
      ),
      bottomNavigationBar: BottomNav(
        selectedIndex: 1,
      ),
    );
  }
}
