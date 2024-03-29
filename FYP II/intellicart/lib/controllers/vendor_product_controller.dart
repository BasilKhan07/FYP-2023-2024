import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VendorProductController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getProductsStream() {
    return _firestore
        .collection('vendors')
        .doc(_auth.currentUser!.uid)
        .collection('products')
        .snapshots();
  }

  Future<String> addProduct(String name, String category, String price) async {
    try {
      await _firestore
          .collection('vendors')
          .doc(_auth.currentUser!.uid)
          .collection('products')
          .add({
        'name': name,
        'category': category,
        'price': double.parse(price),
      });
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> updateProduct(
      String name, String category, String price) async {
    try {
      final querySnapshot = await _firestore
          .collection('vendors')
          .doc(_auth.currentUser!.uid)
          .collection('products')
          .where('name', isEqualTo: name)
          .where('category', isEqualTo: category)
          .get();

      for (final doc in querySnapshot.docs) {
        await doc.reference.update({
          'price': double.parse(price),
        });
      }

      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

   Future<String> deleteProduct(String name, String category) async {
    try {
      final querySnapshot = await _firestore
          .collection('vendors')
          .doc(_auth.currentUser!.uid)
          .collection('products')
          .where('name', isEqualTo: name)
          .where('category', isEqualTo: category)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (final doc in querySnapshot.docs) {
          await doc.reference.delete();
        }
        return 'success';
      } else {
        return 'No matching products found for deletion.';
      }
    } catch (e) {
      return 'Error deleting product: $e';
    }
  }
}
