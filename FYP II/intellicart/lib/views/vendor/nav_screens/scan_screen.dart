import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late bool _isRecording;
  late XFile? _videoFile;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user; //user.uid

  @override
  void initState() {
    super.initState();
    _isRecording = false;
    _initializeControllerFuture = _initializeCamera();
    user = _auth.currentUser;
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.high);
    return _controller.initialize();
  }

  // Future<String> _getVideoFilePath() async {
  //   final appDir = await getTemporaryDirectory();
  //   return '${appDir.path}/${DateTime.now()}.mp4';
  // }

  Future<void> _startRecording() async {
    try {
      await _initializeControllerFuture;
      // final filePath = await _getVideoFilePath();
      await _controller.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
    }
  }

  Future<void> _stopRecording() async {
    try {
      final videoFile = await _controller.stopVideoRecording();
      setState(() {
        _videoFile = videoFile;
        _isRecording = false;
      });
      if (_isRecording == false) {
        // Show upload status prompt
        _showUploadStatusPrompt(
            true, "Video will be uploaded soon! Please wait");

        //print('Video uploaded successfully');
      }

      // Upload the recorded video file to API endpoint
      final url = Uri.parse('http://172.16.83.66:8020/upload_video/');
      var request = http.MultipartRequest('POST', url);
      request.files.add(
          await http.MultipartFile.fromPath('video_file', _videoFile!.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        // Parse the response and save the results to vendor collection database
        String responseBody = await response.stream.bytesToString();

        saveResultsToDatabase(responseBody);
        if (await saveResultsToDatabase(responseBody)) {
          _showUploadStatusPrompt(true, "Video Uploaded Successfully");
        }
        // _sendpushnotification();
      } else {
      }
    } catch (e) {
    }
  }

  Future<bool> saveResultsToDatabase(String responseBody) async {
    try {
      // Parse the response body if needed
      var data = json.decode(responseBody);
      DateTime now = DateTime.now();
      String formattedDate = '${now.year}-${now.month}-${now.day}';

      // Save the results to the vendor collection database
      // Get a reference to the collection and document where you want to add data
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection('vendors')
          .doc(user!.uid) // Assuming user is already defined and authenticated
          .collection('video_results')
          .doc(formattedDate); // Use the formatted date as the document ID

      // Define the data you want to add

      // Add the data to the document
      await documentReference.set(data); // Add to a subcollection if needed

      return true;
    } catch (e) {
      return false;
    }
  }

  void _showUploadStatusPrompt(bool uploadedSuccessfully, String status) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(uploadedSuccessfully ? 'Upload status' : 'Upload Failed'),
          content: Text(
              uploadedSuccessfully ? status : 'Failed to upload the video.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Center(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width *
                    _controller.value.aspectRatio,
                child: CameraPreview(_controller),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isRecording ? _stopRecording : _startRecording,
        child: Icon(_isRecording ? Icons.stop : Icons.fiber_manual_record),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
