import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sign_language_trasnlator2/image_helper/image_classification_helper.dart';
import 'package:sign_language_trasnlator2/utility/bottom_nav.dart';

class Camera2Page extends StatefulWidget {
  @override
  _Camera2PageState createState() => _Camera2PageState();
}

class _Camera2PageState extends State<Camera2Page> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  String _prediction = "No predictions yet";

  bool _isProcessing = false;
  late Map<String, double> classification;
  late ImageClassificationHelper imageClassificationHelper;
  late List<MapEntry<String, double>> sortedResults;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    imageClassificationHelper = ImageClassificationHelper();
    await imageClassificationHelper.initHelper(); // load model and labels
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _cameraController = CameraController(
        _cameras![0],
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await _cameraController!.initialize();
      setState(() {});

      _cameraController?.startImageStream(
        (CameraImage image) async {
          // Process each frame here, only after done processing the previous one
          if (_isProcessing) {
            return;
          }

          setState(() {
            _isProcessing = true;
          });

          // log("Attempting classification");
          // using image_classification_helper to do all the work, model setup and loading labels is done in that file
          classification =
              await imageClassificationHelper.inferenceCameraFrame(image);
          // log("Classification done");

          String topResult = sortClassification(classification);
          setState(() {
            _prediction = topResult; // to show on screen
            _isProcessing = false;
          });
        },
      );
    }
  }

  String sortClassification(Map<String, double> classification) {
    sortedResults = classification.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    List<String> topResults = [];
    for (int i = sortedResults.length - 1; i >= 0; i--) {
      topResults.add(sortedResults[i].key);
      log(sortedResults[i].value.toString() + " " + sortedResults[i].key);
    }
    log("Top results: " + topResults[0].toString());
    return topResults[0];
  }

  @override
  void dispose() {
    super.dispose();
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    imageClassificationHelper.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Camera with Prediction',
          style: GoogleFonts.lato(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepOrangeAccent,
        centerTitle: true,
        elevation: 5,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: _cameraController != null &&
                    _cameraController!.value.isInitialized
                ? CameraPreview(_cameraController!)
                : Center(child: CircularProgressIndicator()),
          ),
          Container(
            color: Colors.black,
            padding: EdgeInsets.all(16.0),
            child: Text(
              _prediction,
              style: TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
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
