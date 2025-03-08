import 'package:flutter/material.dart';
import 'package:sign_language_trasnlator2/utility/bottom_nav.dart';
import 'package:camerawesome/camerawesome_plugin.dart';

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
          Container(
            height: 400,
            width: 400,
            child: CameraAwesomeBuilder.awesome(
              saveConfig: SaveConfig.photoAndVideo(),
              onMediaTap: (mediaCapture) {
                print("take picture");
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(
        selectedIndex: 1,
      ),
    );
  }
}
