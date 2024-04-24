import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VendorDashboardController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user = FirebaseAuth.instance.currentUser; //user.uid
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<dynamic>> getNoOfCategories_getNoOfFruitsandVeg() async {
    List output = [];
    late int noOfCategories;
    Map categories = {};
    final user = this.user;
    if (user != null) {
      QuerySnapshot vendorProducts = await FirebaseFirestore.instance
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
      noOfCategories = categories.length;
      output.add(noOfCategories);
      output.add(categories['Fruit'] ?? 0);
      output.add(categories['Vegetables'] ?? 0);

      return output;
  }

  // double _calculateTotalCost(double price) {
  //   return price * _quantity;
  // }



//   Future<void> _fetchSalesByDate(DateTime selectedDate) async {
//   try {
//     String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
//     DocumentSnapshot salesDoc = await FirebaseFirestore.instance
//         .collection('vendors')
//         .doc(_vendorId)
//         .collection('sales')
//         .doc(formattedDate)
//         .get();

//     if (salesDoc.exists) {
//       Map<String, dynamic> salesData = salesDoc.data() as Map<String, dynamic>;

//       // Display total cost for the selected date
//       double totalCost = salesData['totalCost'] ?? 0.0;
//       print('Total Cost for $_selectedDate: $totalCost');

//       // Display products sold with their quantities
//       salesData.forEach((productId, productData) {
//         if (productId != 'totalCost' && productId != 'date') {
//           String productName = _products!
//               .firstWhere((product) => product.id == productId)['name'];
//           int quantity = productData as int; // Get the quantity directly
//           print('$productName: $quantity');
//         }
//       });
//     } else {
//       print('No sales recorded for $_selectedDate');
//     }
//   } catch (e) {
//     print('Error fetching sales: $e');
//     // Handle error
//   }
// }

}
