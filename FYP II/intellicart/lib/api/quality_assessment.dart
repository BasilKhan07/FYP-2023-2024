import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<String> predictImage(File? image) async {
  String apiUrl =
      'http://172.20.10.6:8000/predict/'; //use your PC's IP. go to ipconfig and then find your IP there.
  var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
  request.files.add(await http.MultipartFile.fromPath('image', image!.path));
  var streamedResponse = await request.send();
  var response = await http.Response.fromStream(streamedResponse);

  try {
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      List<dynamic> predictions = responseData['predictions'];
      if (predictions.isNotEmpty) {
        return predictions.first;
      } else {
        return 'No prediction found';
      }
    } else {
      return 'Failed to make a request. Status code: ${response.statusCode}';
    }
  } catch (e) {
    return 'Error: $e';
  }
}
