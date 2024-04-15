import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:intellicart/api/quality_assessment.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ImagePredictionPage extends StatefulWidget {
  const ImagePredictionPage({super.key});

  @override
  _ImagePredictionPageState createState() => _ImagePredictionPageState();
}

class _ImagePredictionPageState extends State<ImagePredictionPage> {
  String _prediction = '';
  final picker = ImagePicker();
  File? _image;

  Future getImageFromGallery() async {
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    _setImage(pickedFile);
  }

  Future getImageFromCamera() async {
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);
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

    String apiUrl = 'http://192.168.0.106:8001/predict/'; //use your PC's IP. go to ipconfig and then find your IP there.
    // wifi on phone and laptop should be same 
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
    var streamedResponse = await request.send();
    print('AAA');
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
              maxHeight: MediaQuery.of(context).size.height * 0.4, 
            ),
            child: Center(
              child: _image == null ? const Text('No image selected.') : Image.file(_image!),
            ),
          ),
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: getImageFromGallery,
                child: const Text('Select Image'),
              ),
              ElevatedButton(
                onPressed: getImageFromCamera,
                child: const Text('Take Picture'),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: predictImage,
            child: const Text('Predict'),
          ),
          const SizedBox(height: 20.0),
          Text('Prediction: $_prediction'),
        ],
      ),
    );
  }
}

// class QualityAssessmentScreen extends StatefulWidget {
//    const QualityAssessmentScreen({super.key});

//   @override
//   State<QualityAssessmentScreen> createState() => _QualityAssessmentScreenState();
// }

// class _QualityAssessmentScreenState extends State<QualityAssessmentScreen> {
//   String _prediction = '';

//   final picker = ImagePicker();
//   File? _image;

//   Future getImageFromGallery() async {
//     final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     _setImage(pickedFile);
//   }

//   Future getImageFromCamera() async {
//     final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);
//     _setImage(pickedFile);
//   }

//   void _setImage(XFile? pickedFile) {
//     setState(() {
//       if (pickedFile != null) {
//         _image = File(pickedFile.path);
//       } 
//     });
//   }

//   predict() async {
//     if (_image != null) {
//       String predictionResult = await predictImage(_image);
//       setState(() {
//         _prediction = predictionResult;
//       });
//     } else {
//       setState(() {
//         _prediction = 'No image selected.';
//       });
//     }
//   }

//  @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           Container(
//             constraints: BoxConstraints(
//               maxWidth: MediaQuery.of(context).size.width * 0.8,
//               maxHeight: MediaQuery.of(context).size.height * 0.4, 
//             ),
//             child: Center(
//               child: _image == null ? const Text('No image selected.') : Image.file(_image!),
//             ),
//           ),
//           const SizedBox(height: 20.0),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               ElevatedButton(
//                 onPressed: getImageFromGallery,
//                 child: const Text('Select Image'),
//               ),
//               ElevatedButton(
//                 onPressed: getImageFromCamera,
//                 child: const Text('Take Picture'),
//               ),
//             ],
//           ),
//           ElevatedButton(
//             onPressed: predict,
//             child: const Text('Predict'),
//           ),
//           const SizedBox(height: 20.0),
//           Text('Prediction: $_prediction'),
//         ],
//       ),
//     );
//   }
// }

// ignore_for_file: library_private_types_in_public_api

// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';

// class ImagePredictionPage extends StatefulWidget {
//   const ImagePredictionPage({super.key});

//   @override
//   _ImagePredictionPageState createState() => _ImagePredictionPageState();
// }

// class _ImagePredictionPageState extends State<ImagePredictionPage> {
//   String _prediction = '';
//   final picker = ImagePicker();
//   File? _image;

//   Future getImageFromGallery() async {
//     final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     _setImage(pickedFile);
//   }

//   Future getImageFromCamera() async {
//     final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);
//     _setImage(pickedFile);
//   }

//   void _setImage(XFile? pickedFile) {
//     setState(() {
//       if (pickedFile != null) {
//         _image = File(pickedFile.path);
//       } 
//     });
//   }

//   Future predictImage() async {
//     if (_image == null) return;

//     String apiUrl = 'http://172.20.10.6:8000/predict/'; //use your PC's IP. go to ipconfig and then find your IP there. 
//     var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
//     request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
//     var streamedResponse = await request.send();
//     var response = await http.Response.fromStream(streamedResponse);

//     if (response.statusCode == 200) {
//       Map<String, dynamic> responseData = json.decode(response.body);
//       List<dynamic> predictions = responseData['predictions'];
//       if (predictions.isNotEmpty) {
//         setState(() {
//           _prediction = predictions.first;
//         });
//       } else {
//         setState(() {
//           _prediction = 'No prediction found';
//         });
//       }
//     } 
//   }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           Container(
//             constraints: BoxConstraints(
//               maxWidth: MediaQuery.of(context).size.width * 0.8,
//               maxHeight: MediaQuery.of(context).size.height * 0.4, 
//             ),
//             child: Center(
//               child: _image == null ? const Text('No image selected.') : Image.file(_image!),
//             ),
//           ),
//           const SizedBox(height: 20.0),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               ElevatedButton(
//                 onPressed: getImageFromGallery,
//                 child: const Text('Select Image'),
//               ),
//               ElevatedButton(
//                 onPressed: getImageFromCamera,
//                 child: const Text('Take Picture'),
//               ),
//             ],
//           ),
//           ElevatedButton(
//             onPressed: predictImage,
//             child: const Text('Predict'),
//           ),
//           const SizedBox(height: 20.0),
//           Text('Prediction: $_prediction'),
//         ],
//       ),
//     );
//   }
// }
