import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sign_language_trasnlator2/image_helper/image_classification_helper.dart';
import 'package:sign_language_trasnlator2/utility/bottom_nav.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../utility/firebase_info.dart';

final _firestore = FirebaseFirestore.instance; //for the database

class Camera2Page extends StatefulWidget {
  @override
  _Camera2PageState createState() => _Camera2PageState();
}

class _Camera2PageState extends State<Camera2Page> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  String _prediction = "No predictions yet";
  String _previousPrediction = "";
  int _predictionCount = 0;
  String _predictedText = "";

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
          classification = await imageClassificationHelper.inferenceCameraFrame(image);
          // log("Classification done");

          String topResult = sortClassification(classification);

          setState(() {
            _prediction = topResult; // to show on screen
            _isProcessing = false;
            checkIfSameCharacter();
          });
        },
      );
    }
  }

  void checkIfSameCharacter() {
    if (_prediction == "No sign detected" || _prediction.isEmpty || _prediction == "nothing") {
      return; // skip processing if no valid prediction
    }
    if (_prediction == _previousPrediction) {
      log("Same character detected: $_prediction");
      _predictionCount++;
      if (_predictionCount >= 5) {
        log("Character $_prediction detected 5 times in a row");
        _predictedText += _prediction; // append to predicted text
        _predictionCount = 0; // reset count after reaching threshold
      }
    } else {
      log("New character detected: $_prediction");
      _predictionCount = 0; // reset count for new character
      _previousPrediction = _prediction; // update previous prediction
    }
  }

  String sortClassification(Map<String, double> classification) {
    sortedResults = classification.entries.toList()..sort((a, b) => a.value.compareTo(b.value));
    // List<String> topResults = [];
    // Get top 5 results
    // for (int i = 0; i < 5; i++) {
    //   if (i >= sortedResults.length) break;
    //   topResults.add(sortedResults[i].key);
    //   log(sortedResults[i].value.toString() + " " + sortedResults[i].key);
    // }
    log("Top results: ${sortedResults[0].key} with score: ${sortedResults[0].value}");
    if (sortedResults[0].value > 0.02) {
      return sortedResults[0].key;
    } else {
      return "nothing";
    }
    // return sortedResults[0].key; // return only the top result
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
            child: _cameraController != null && _cameraController!.value.isInitialized
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Text: ",
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
              Expanded(
                child: AutoSizeText(
                  _predictedText,
                  style: TextStyle(color: Colors.black, fontSize: 18),
                  textAlign: TextAlign.left,
                ),
              ),
              TextButton(
                onPressed: () async {
                  // send text to firebase and clear text
                  await sendTextToFirebase();
                },
                child: Text(
                  "Save",
                  style: TextStyle(fontSize: 18),
                ),
              )
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(
        selectedIndex: 1,
      ),
    );
  }

  Future<void> sendTextToFirebase() async {
    if (_predictedText == "") {
      return;
    }
    try {
      Map<String, String> data = {DateTime.now().toString().split(" ")[1]: _predictedText};
      await setTextDatabase(data);
      _predictedText = "";

      // data is in the form of {date:Map} -> Map = {time:text}
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> setTextDatabase(Map<String, String> data) async {
    await _firestore.collection('chat_history').doc(loggedInUser.email).set(
      {DateTime.now().toString().split(" ")[0]: data},
      SetOptions(merge: true),
    );
  }
}
