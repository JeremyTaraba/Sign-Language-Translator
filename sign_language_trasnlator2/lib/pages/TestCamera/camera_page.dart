import 'package:flutter/material.dart';
import 'package:sign_language_trasnlator2/pages/TestCamera/camerascreen.dart';
import 'package:tflite/tflite.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
// trying to use google mlkit, will need to check the github examples
// need to remove tflite from pubspec, it won't compile with it

class CameraPage extends StatefulWidget {
  const CameraPage({super.key, required this.cameras});
  final List<CameraDescription> cameras;
  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  String predOne = '';

  @override
  void initState() {
    super.initState();
    loadTfliteModel();
  }

  loadTfliteModel() async {
    String? res;
    res = await Tflite.loadModel(
        model: "assets/model_unquant.tflite", labels: "assets/labels.txt");
    print(res);
  }

  setRecognitions(outputs) {
    setState(() {
      predOne = outputs[0]['label'];
    });
  }

  void processImage(objectDetector, inputImage) async {
    final List<DetectedObject> objects =
        await objectDetector.processImage(inputImage);

    for (DetectedObject detectedObject in objects) {
      final rect = detectedObject.boundingBox;
      final trackingId = detectedObject.trackingId;

      for (Label label in detectedObject.labels) {
        print('${label.text} ${label.confidence}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = DetectionMode.stream;
    final options = LocalObjectDetectorOptions(
        mode: mode,
        modelPath: "assets/model_unquant.tflite",
        classifyObjects: true,
        multipleObjects: false);
    final objectDetector = ObjectDetector(options: options);

    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "TensorFlow Lite App",
        ),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          Camera(widget.cameras, setRecognitions),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 100.0,
              decoration: BoxDecoration(
                  color: Colors.blueGrey,
                  boxShadow: [BoxShadow(color: Colors.black, blurRadius: 20.0)],
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
                    "$predOne",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.tealAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
