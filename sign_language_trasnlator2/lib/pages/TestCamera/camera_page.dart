import 'package:flutter/material.dart';
import 'package:sign_language_trasnlator2/pages/TestCamera/camerastream.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:sign_language_trasnlator2/utility/image_helper/image_classification_helper.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:sign_language_trasnlator2/utility/bottom_nav.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
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
  late final Interpreter interpreter;

  late Tensor inputTensor;

  late Tensor outputTensor;

  late final List<String> labels;

  img.Image? image;

  final bool _isProcessing = false;

  late Map<String, double> classification;

  late ImageClassificationHelper imageClassificationHelper;

  late List<String> topResults;
  late List<MapEntry<String, double>> sortedResults;

  late InputImage inputImage;

  late ObjectDetector objectDetector;

  @override
  void initState() {
    super.initState();
  }

  // createObjectDetector() {
  //   final mode = DetectionMode.stream;
  //   final options = ObjectDetectorOptions(
  //       mode: mode, classifyObjects: true, multipleObjects: false);
  //   objectDetector = ObjectDetector(options: options);
  // }

  processImage() async {
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
    final mode = DetectionMode.stream;
    final options = LocalObjectDetectorOptions(
        mode: mode,
        modelPath: "assets/model.tflite",
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
          Camera(widget.cameras, setRecognitions, objectDetector),
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
      bottomNavigationBar: BottomNav(
        selectedIndex: 0,
      ),
    );
  }
}
