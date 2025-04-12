import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

typedef void Callback(List<dynamic> list);

class Camera extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Callback setRecognitions;
  final ObjectDetector objectDetector;

  Camera(this.cameras, this.setRecognitions, this.objectDetector);
  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  late CameraController cameraController;
  bool isDetecting = false;

  processImage(objectDetector, inputImage) async {
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
  void initState() {
    super.initState();
    cameraController =
        CameraController(widget.cameras.first, ResolutionPreset.high);
    cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {});

      cameraController.startImageStream((image) {
        if (!isDetecting) {
          isDetecting = true;
          processImage(widget.objectDetector, image);
          // Tflite.runModelOnFrame(
          //   bytesList: image.planes.map((plane) {
          //     return plane.bytes;
          //   }).toList(),
          //   imageHeight: image.height,
          //   imageWidth: image.width,
          //   numResults: 1,
          // ).then((value) {
          //   if (value!.isNotEmpty) {
          //     widget.setRecognitions(value);
          //     isDetecting = false;
          //   }
          // });
        }
      });
    });
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!cameraController.value.isInitialized) {
      return Container();
    }

    return Transform.scale(
      scale: 1 / cameraController.value.aspectRatio,
      child: Center(
        child: AspectRatio(
          aspectRatio: cameraController.value.aspectRatio,
          child: CameraPreview(cameraController),
        ),
      ),
    );
  }
}
