import 'package:flutter/material.dart';
import 'package:sign_language_trasnlator2/pages/TestCamera/camerastream.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:sign_language_trasnlator2/utility/bottom_nav.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';

// model will not work with google ml kit, quantized or in float form, both don't work
// will have to use tflite_flutter package instead, need to test it

class CameraPage extends StatefulWidget {
  const CameraPage({super.key, required this.cameras});
  final List<CameraDescription> cameras;
  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  String predOne = '';

  late ObjectDetector objectDetector;

  late Interpreter interpreter;
  late ImageProcessor imageProcessor;
  late TensorImage inputImage;

  @override
  void initState() {
    super.initState();
  }

  Future<void> loadModel() async {
    interpreter = await Interpreter.fromAsset('assets/model.tflite');

    // 👇 Get input shape and type (e.g. [1, 224, 224, 3])
    final inputShape = interpreter.getInputTensor(0).shape;
    final inputType = interpreter.getInputTensor(0).type;

    imageProcessor = ImageProcessorBuilder()
        .add(ResizeOp(inputShape[1], inputShape[2], ResizeMethod.bilinear))
        .add(NormalizeOp(127.5, 127.5)) // normalize to [-1, 1]
        .build();
  }

  Future<String> createObjectDetector() async {
    await loadModel();
    return "Done";
    //   print("starting creation");
    //   final modelPath = await getModelPath('assets/model_unquant.tflite');
    //   print("path got");
    //   final options = LocalObjectDetectorOptions(
    //     mode: DetectionMode.stream,
    //     modelPath: modelPath,
    //     classifyObjects: true,
    //     multipleObjects: false,
    //   );

    //   objectDetector = ObjectDetector(options: options);
    //   print("detector made");
    //   return objectDetector.id;
    // }

    // Future<String> getModelPath(String asset) async {
    //   final path = '${(await getApplicationSupportDirectory()).path}/$asset';
    //   await Directory(dirname(path)).create(recursive: true);
    //   final file = File(path);
    //   if (!await file.exists()) {
    //     final byteData = await rootBundle.load(asset);
    //     await file.writeAsBytes(byteData.buffer
    //         .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    //   }
    //   return file.path;
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
    final outputTensor = interpreter.getOutputTensor(0);
    final outputShape = outputTensor.shape;
    final outputType = outputTensor.type;

    print('Output shape: $outputShape');
    print('Output type: $outputType');
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
