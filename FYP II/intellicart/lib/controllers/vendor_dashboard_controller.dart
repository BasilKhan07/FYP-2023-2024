import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';


class VendorDashboardController {
  User? user = FirebaseAuth.instance.currentUser; //user.uid
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ignore: non_constant_identifier_names
  Stream<List<dynamic>> getNoOfCategories_getNoOfFruitsandVeg() async* {
    List output = [];
    late int noOfCategories;
    Map categories = {};
    final user = this.user;
    if (user != null) {
      QuerySnapshot vendorProducts = await _firestore
          .collection('vendors')
          .doc(user.uid)
          .collection('products')
          .get();

      for (var productDoc in vendorProducts.docs) {
        Map<String, dynamic> data = productDoc.data() as Map<String, dynamic>;
        // Access a specific field in the document
        dynamic category = data['category'];
        if (!categories.containsKey(category)){
          categories[category] = 1;
        }else{
          categories[category]+=1;
        }
        //print('Category: $category');
      }
    }
      //Collecting data for output
      noOfCategories = categories.length;
      output.add(noOfCategories);
      output.add(categories['Fruit'] ?? 0);
      output.add(categories['Vegetable'] ?? 0);
      // Get today's total sale
      await for (List<dynamic> todayTotalSaleAndCust in getTodayTotalSale()) {
        // Update the variable with the new value emitted from the stream
        output.add(todayTotalSaleAndCust[0]);
        output.add(todayTotalSaleAndCust[1]);
        //print('Today\'s total sale: $todayTotalSale');
      }
      print(output);
      yield output;
  }

  Stream<List> getTodayTotalSale() async* {
    List<dynamic> returnList = [0,0];
    double todayTotalSale = 0;
    String formattedTodaysDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    DocumentReference salesRef = _firestore
        .collection('vendors')
        .doc(user!.uid)
        .collection('sales')
        .doc(formattedTodaysDate);

        DocumentSnapshot todaySaleDoc = await salesRef.get();
        // Check if the document exists and has data
        if (todaySaleDoc.exists) {
          // Get the data map from the document snapshot
          Map<String, dynamic> data = todaySaleDoc.data() as Map<String, dynamic>;
          int totalFields = data.length;

          // Iterate over the keys of the data map
          for (String key in data.keys) {
            // Access each field value using the key
            double eachPrice = data[key]['totalCost'];
            todayTotalSale = todayTotalSale + eachPrice;
          }
          returnList = [todayTotalSale, totalFields];
        } else {
          print('Document does not exist.');
        }

        yield returnList;
  }
}