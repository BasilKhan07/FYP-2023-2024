import 'package:cloud_firestore/cloud_firestore.dart';

class VendorSaleController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> addSale(String productName, String category, String quantity,
      String totalPrice, DateTime date) async {
    try {
      await _firestore.collection('sales').add({
        'productName': productName,
        'category': category,
        'quantity': int.parse(quantity),
        'totalPrice': double.parse(totalPrice),
        'date': Timestamp.fromDate(date),
      });
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }
}
