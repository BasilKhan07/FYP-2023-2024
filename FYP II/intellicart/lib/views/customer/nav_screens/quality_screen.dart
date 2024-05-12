import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ImagePredictionPage extends StatefulWidget {
  const ImagePredictionPage({Key? key});

  @override
  _ImagePredictionPageState createState() => _ImagePredictionPageState();
}

class _ImagePredictionPageState extends State<ImagePredictionPage> {
  String _prediction = '';
  final picker = ImagePicker();
  File? _image;

  Future getImageFromGallery() async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    _setImage(pickedFile);
  }

  Future getImageFromCamera() async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.camera);
    _setImage(pickedFile);
  }

  void _setImage(XFile? pickedFile) {
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future predictImage() async {
    if (_image == null) return;

    String apiUrl =
        'http://192.168.18.15:8050/predict/'; //use your PC's IP. go to ipconfig and then find your IP there.
    // wifi on phone and laptop should be same
    var request =
        http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.files
        .add(await http.MultipartFile.fromPath('image', _image!.path));
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      List<dynamic> predictions = responseData['predictions'];
      if (predictions.isNotEmpty) {
        setState(() {
          _prediction = predictions.first;
        });
      } else {
        setState(() {
          _prediction = 'No prediction found';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 6, 24, 8), 
              Color.fromARGB(255, 109, 161, 121), 
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: Center(
                child: _image == null
                    ? const Text(
                        'No image selected.',
                        style: TextStyle(color: Colors.white),
                      )
                    : Image.file(_image!),
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: getImageFromGallery,
                  child: const Text(
                    'Select Image',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black87,
                  ),
                ),
                ElevatedButton(
                  onPressed: getImageFromCamera,
                  child: const Text(
                    'Take Picture',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black87,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: predictImage,
              child: const Text(
                'Predict',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.black87,
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              'Prediction: $_prediction',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
