import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VendorProductController {
  User? user = FirebaseAuth.instance.currentUser; //user.uid
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<Map> getProductsinCategoryStream() async* {
    final user = this.user;

    Map output = {'Vegetables': [],
                  'Fruits' : []
                  };
    if (user != null) {
      QuerySnapshot vendorProductsinCategories = await _firestore
          .collection('vendors')
          .doc(user.uid)
          .collection('products')
          .get();

     for (var productDoc in vendorProductsinCategories.docs) {
        Map<String, dynamic> data = productDoc.data() as Map<String, dynamic>;
        // chck for category and place accordingly in output
        //print(data);
        dynamic category = data['category'];
        if (category == 'Vegetable'){
          output['Vegetables'].add(data);
        }else if (category == 'Fruit'){
          output['Fruits'].add(data);
        }
      }
    }

    print('output is  ----------------->   $output');
    yield output;
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

  Future<List<String>> getProductNames() async {
  List<String> productNames = [];
  try {
    QuerySnapshot productSnapshot = await _firestore
        .collection('vendors')
        .doc(_auth.currentUser!.uid)
        .collection('products')
        .get();
    
    productSnapshot.docs.forEach((productDoc) {
      String productName = productDoc['name'];
      productNames.add(productName);
    });

    return productNames;
  } catch (e) {
    return []; 
  }
}
}
