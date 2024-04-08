
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerVendorController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Object>> getVendors(){
    return _firestore.collection('vendors').snapshots();
  }
}