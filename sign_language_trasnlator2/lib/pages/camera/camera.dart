import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sign_language_trasnlator2/utility/bottom_nav.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image_picker/image_picker.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;
  bool _isModelLoaded = false;

  late Interpreter interpreter;
  late List<String> labels;

  final int inputSize = 224; // Change to match your model's input size
  final int inputChannels = 3;

  bool isProcessing = false;

  String _predictedLabel = '';
  double _confidence = 0.0;

  @override
  void initState() {
    super.initState();
    _loadModel();
    _initializeCamera();
  }

  Future<void> _loadModel() async {
    interpreter = await Interpreter.fromAsset('assets/model.tflite');
    labels = await rootBundle
        .loadString('assets/labels.txt')
        .then((value) => value.split("\n"));
    setState(() {
      _isModelLoaded = true;
    });
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(
      _cameras[0],
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _cameraController.initialize();
    _cameraController.startImageStream((CameraImage image) {
      if (!isProcessing && _isModelLoaded) {
        isProcessing = true;
        _runModelOnFrame(image).then((_) {
          isProcessing = false;
        });
      }
    });
    setState(() {
      _isCameraInitialized = true;
    });
  }

  Future<void> _runModelOnFrame(CameraImage image) async {
    final img.Image convertedImage = _convertCameraImage(image);
    final img.Image resizedImage =
        img.copyResize(convertedImage, width: inputSize, height: inputSize);
    final List<int> inputBuffer = resizedImage.getBytes(format: img.Format.rgb);
    // final imageBytes = await image.toByteData(format: ImageByteFormat.rawRgba);
    // final input = imageToByteListFloat32(imageBytes, 224, 224, 3);
    final output = List<List<dynamic>>.filled(
        1, List<dynamic>.filled(1001, 0)); // Assuming 1001 output classes

    interpreter.run(image, output); //TODO: The image here should be in bytes

    // Get list of probabilities
    final probabilities = output[0];

    final topIndex = probabilities.indexWhere(
      (element) => element == probabilities.reduce((a, b) => a > b ? a : b),
    );

    final label = labels[topIndex];
    final confidence = probabilities[topIndex];

    debugPrint(
        'Prediction: $label (${(confidence * 100).toStringAsFixed(2)}%)');

    setState(() {
      _predictedLabel = labels[topIndex];
      _confidence = probabilities[topIndex];
    });
  }

  img.Image _convertCameraImage(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final yPlane = image.planes[0];
    final uvRowStride = image.planes[1].bytesPerRow;

    final img.Image imgImage = img.Image(width, height);
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        final uvIndex = uvRowStride * (i ~/ 2) + (j & ~1);
        final y = yPlane.bytes[i * width + j];
        final u = image.planes[1].bytes[uvIndex];
        final v = image.planes[2].bytes[uvIndex];

        int r = (y + (1.370705 * (v - 128))).toInt();
        int g = (y - (0.337633 * (u - 128)) - (0.698001 * (v - 128))).toInt();
        int b = (y + (1.732446 * (u - 128))).toInt();

        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        imgImage.setPixelRgba(j, i, r, g, b);
      }
    }
    return imgImage;
  }

  @override
  void dispose() {
    _cameraController.dispose();
    interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera'),
      ),
      body: _isCameraInitialized && _isModelLoaded
          ? Column(
              children: [
                Expanded(child: CameraPreview(_cameraController)),
                Container(
                  color: Colors.black,
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  child: Text(
                    _predictedLabel.isNotEmpty
                        ? 'Prediction: $_predictedLabel (${(_confidence * 100).toStringAsFixed(2)}%)'
                        : 'Waiting for prediction...',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
      bottomNavigationBar: BottomNav(
        selectedIndex: 1,
      ),
    );
  }
}
