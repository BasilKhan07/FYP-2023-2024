import 'package:cloud_firestore/cloud_firestore.dart';

class VendorSalesController {
  final String vendorId;

  VendorSalesController(this.vendorId);

  Future<List<DocumentSnapshot>> fetchProducts() async {
    try {
      QuerySnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('vendors')
          .doc(vendorId)
          .collection('products')
          .get();
      return productSnapshot.docs;
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  Future<void> recordSale(String productId, int quantity) async {
  try {
    DateTime now = DateTime.now();
    String formattedDate = '${now.year}-${now.month}-${now.day}';
    DocumentReference salesRef = FirebaseFirestore.instance
        .collection('vendors')
        .doc(vendorId)
        .collection('sales')
        .doc(formattedDate);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot salesDoc = await transaction.get(salesRef);

      double productPrice = await getProductPrice(productId) ?? 0;
      double totalCost = productPrice * quantity;

      if (salesDoc.exists) {
        Map<String, dynamic> data = salesDoc.data() as Map<String, dynamic>;
        int currentQuantity = data[productId] ?? 0;
        data[productId] = currentQuantity + quantity;
        data['totalCost'] = (data['totalCost'] ?? 0) + totalCost;
        transaction.update(salesRef, data);
      } else {
        Map<String, dynamic> data = {
          productId: quantity,
          'totalCost': totalCost,
        };
        transaction.set(salesRef, data);
      }
    });
    print('Sale recorded successfully.');
  } catch (e) {
    print('Error recording sale: $e');
    throw Exception('Failed to record sale. Please try again.');
  }
}


  Future<double?> getProductPrice(String productId) async {
    try {
      DocumentSnapshot productDoc = await FirebaseFirestore.instance
          .collection('vendors')
          .doc(vendorId)
          .collection('products')
          .doc(productId)
          .get();
      return productDoc['price'];
    } catch (e) {
      throw Exception('Error fetching product price: $e');
    }
  }
}
