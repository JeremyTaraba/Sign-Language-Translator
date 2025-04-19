import 'package:flutter/material.dart';
import 'package:sign_language_trasnlator2/pages/TestCamera/camerastream.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:sign_language_trasnlator2/utility/bottom_nav.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

// make sure the tflite model is quantized or it wont work

class CameraPage extends StatefulWidget {
  const CameraPage({super.key, required this.cameras});
  final List<CameraDescription> cameras;
  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  String predOne = '';

  late ObjectDetector objectDetector;

  @override
  void initState() {
    super.initState();
  }

  Future<String> createObjectDetector() async {
    print("starting creation");
    final modelPath = await getModelPath('assets/model_unquant.tflite');
    print("path got");
    final options = LocalObjectDetectorOptions(
      mode: DetectionMode.stream,
      modelPath: modelPath,
      classifyObjects: true,
      multipleObjects: false,
    );

    objectDetector = ObjectDetector(options: options);
    print("detector made");
    return objectDetector.id;
  }

  Future<String> getModelPath(String asset) async {
    final path = '${(await getApplicationSupportDirectory()).path}/$asset';
    await Directory(dirname(path)).create(recursive: true);
    final file = File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(asset);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }

  setRecognitions(outputs) {
    setState(() {
      predOne = outputs[0]['label'];
    });
  }

  @override
  void dispose() {
    objectDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      body: FutureBuilder<dynamic>(
        future: createObjectDetector(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return Stack(
              children: [
                Camera(widget.cameras, setRecognitions, objectDetector),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 100.0,
                    decoration: BoxDecoration(
                        color: Colors.orange[50],
                        boxShadow: [
                          BoxShadow(color: Colors.black, blurRadius: 10.0)
                        ],
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(50.0),
                            topRight: Radius.circular(50.0))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 30.0,
                        ),
                        Text(
                          predOne,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            );
          } else {
            return Center(
              child: SizedBox(
                  width: 60, height: 60, child: CircularProgressIndicator()),
            );
          }
        },
      ),
      bottomNavigationBar: BottomNav(
        selectedIndex: 1,
      ),
    );
  }
}
