import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
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

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    cameraController = CameraController(
      widget.cameras.first,
      enableAudio: false,
      ResolutionPreset.medium,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21 // for Android
          : ImageFormatGroup.bgra8888, // for iOS
    );
    await cameraController.initialize();

    await cameraController.startImageStream((image) {
      if (!isDetecting) {
        isDetecting = true;
        final inputImage = inputImageFromCameraImage(
            image, widget.cameras.first.sensorOrientation);
        processImage(widget.objectDetector, inputImage);
      }
      Future.delayed(const Duration(milliseconds: 300)).then((_) {
        isDetecting = false;
      });
    });
    setState(() {});
  }

  processImage(ObjectDetector objectDetector, InputImage inputImage) async {
    print("running processImage");

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

  InputImage inputImageFromCameraImage(CameraImage image, int rotation) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(
      image.width.toDouble(),
      image.height.toDouble(),
    );

    final imageRotation = InputImageRotationValue.fromRawValue(rotation) ??
        InputImageRotation.rotation0deg;

    // construct metadata
    final metadata = InputImageMetadata(
      size: imageSize,
      rotation: imageRotation,
      format: InputImageFormat.nv21,
      bytesPerRow: image.planes.first.bytesPerRow,
    );

    print('format: ${image.format.raw}'); // should be 35
    print('bytesPerRow: ${image.planes.first.bytesPerRow}');
    print('rotation: $rotation');

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: metadata,
    );
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
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;

    return Center(
      child: SizedBox(
        width: width,
        height: height / 2,
        child: AspectRatio(
          aspectRatio: cameraController.value.aspectRatio,
          child: CameraPreview(cameraController),
        ),
      ),
    );
  }
}
