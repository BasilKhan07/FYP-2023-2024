import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class VendorLocationController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<LatLng> getVendorLocation() async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('vendors')
          .doc(_auth.currentUser!.uid)
          .get();

      if (doc.exists) {
        GeoPoint geoPoint = doc['location'];

        double latitude = geoPoint.latitude;
        double longitude = geoPoint.longitude;
        return LatLng(latitude, longitude);
      } else {
        throw Exception('Vendor location not found.');
      }
    } catch (e) {
      throw Exception('Error fetching vendor location: $e');
    }
  }

  Future<String> updateVendorLocation(double latitude, double longitude) async {
    try {
      await _firestore
          .collection('vendors')
          .doc(_auth.currentUser!.uid)
          .update({
        'location': GeoPoint(latitude, longitude),
      });
    } catch (e) {
      return 'Error updating vendor location: $e';
    }
    return 'success';
  }
}
