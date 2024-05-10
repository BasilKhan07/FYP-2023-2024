import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  late String _vendorId;
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late bool _isRecording;
  late XFile? _videoFile;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;  //user.uid

  @override
  void initState() {
    super.initState();
    _isRecording = false;
    _initializeControllerFuture = _initializeCamera();
     _getVendorId();
  }

  Future<void> _getVendorId() async {
    if (user != null) {
      DocumentSnapshot vendorDoc = await FirebaseFirestore.instance
          .collection('vendors')
          .doc(user!.uid)
          .get();
      setState(() {
        _vendorId = vendorDoc.id;
      });
    } else {
      
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.high);
    return _controller.initialize();
  }

  Future<String> _getVideoFilePath() async {
    final appDir = await getTemporaryDirectory();
    return '${appDir.path}/${DateTime.now()}.mp4';
  }

  Future<void> _startRecording() async {
    try {
      await _initializeControllerFuture;
      final filePath = await _getVideoFilePath();
      await _controller.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _stopRecording() async {
    try {
      final videoFile = await _controller.stopVideoRecording();
      setState(() {
        _videoFile = videoFile;
        _isRecording = false;
      });
      print('Video recorded to: ${_videoFile?.path}');

      // Upload the recorded video file to API endpoint
      final url = Uri.parse('http://192.168.18.15:8000/upload_video/');
      var request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath(
          'video_file', _videoFile!.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        // Parse the response and save the results to vendor collection database
        String responseBody = await response.stream.bytesToString();
        saveResultsToDatabase(responseBody);
        print('Video uploaded successfully');
      } else {
        print('Failed to upload video');
      }

      // Show upload status prompt
      _showUploadStatusPrompt(response.statusCode == 200);
    } catch (e) {
      print(e);
    }
  }

  void saveResultsToDatabase(String responseBody) async {
    try {
      // Parse the response body if needed
      var data = json.decode(responseBody);

      // Save the results to the vendor collection database
      await FirebaseFirestore.instance
          .collection('vendors')
          .doc(_vendorId)
          .collection('video_results')
          .add(data);

      print('Results saved to database');
    } catch (e) {
      print('Error saving results to database: $e');
    }
  }

  void _showUploadStatusPrompt(bool uploadedSuccessfully) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(uploadedSuccessfully ? 'Upload Success' : 'Upload Failed'),
          content: Text(uploadedSuccessfully
              ? 'The video has been uploaded successfully.'
              : 'Failed to upload the video.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
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
            return Center(child: CircularProgressIndicator());
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
