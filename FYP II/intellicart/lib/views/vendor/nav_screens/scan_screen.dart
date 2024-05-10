import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late bool _isRecording;
  late XFile? _videoFile;

  @override
  void initState() {
    super.initState();
    _isRecording = false;
    _initializeControllerFuture = _initializeCamera();
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
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Recorder'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
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
