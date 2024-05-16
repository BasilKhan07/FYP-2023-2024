import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PriceFetcher {
  final CollectionReference govtPricesCollection =
      FirebaseFirestore.instance.collection('govt_prices');

  String reduceDay(String inputDate){
    // Parse the input date string into a DateTime object
    DateTime date = DateTime.parse(inputDate);
    // Subtract one day from the date
    DateTime reducedDate = date.subtract(Duration(days: 1));
    String reducedDateinString = DateFormat('yyyy-MM-dd').format(reducedDate);
    print('Coming out of reduceDay func');
    return reducedDateinString;
  }

  Future<Map<String, dynamic>?> fetchDataFromDatabase(String formatteddate, int attempt) async {
    try {
      // Fetch data with specified document ID
      DocumentSnapshot documentSnapshot = await govtPricesCollection.doc(formatteddate).get();

      if (documentSnapshot.exists) {
        print('Got new data');
        // Access the data as a Map<String, dynamic>
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        // Access the specific field within the map using its key
        print(data[formatteddate]);
        return data[formatteddate];
      } else {
        print('Document $formatteddate does not exist');

        // If maximum attempts reached, return null
        if (attempt <= 0) {
          print('Maximum attempts reached');
          return null;
        }

        // Fetch data with another document ID recursively
        String oneDayBeforeFormattedDate = reduceDay(formatteddate);
        print(oneDayBeforeFormattedDate);
        return fetchDataFromDatabase(oneDayBeforeFormattedDate, attempt - 1);
      }
    } catch (error) {
      print('Error accessing document: $error');
      // Handle errors
      return null;
    }
  }


  Future<Map<String, dynamic>?> fetchDataAndStorePrices() async {
    // Get current date
    print('In fetch file');
    DateTime currentDate = DateTime.now();
    String formatteddate = DateFormat('yyyy-MM-dd').format(currentDate);
    //String formatteddate = "2024-04-22"; //temporarily set old date
    print(formatteddate);
    
    try{
      final response = await http.get(Uri.parse('http://20.119.116.21:8030/$formatteddate'));

      if (response.statusCode == 200) {
        Map<String, dynamic> prices = json.decode(response.body);
        print(prices);

        try {
          // Add prices for the current date to Firestore
          await govtPricesCollection.doc(formatteddate).set(prices);
          print('Prices added for date: $formatteddate');
        } catch (e) {
          print('Error adding prices: $e');
        }
      }else{
        print('Error fetching data: ${response.statusCode}');
      }
    }
    catch(e){
      print('Error reaching government price api : $e' );
    }

    //now getting latest date prices available in firebase collections
    return fetchDataFromDatabase(formatteddate, 4);
  }
}
