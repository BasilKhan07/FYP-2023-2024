import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class VendorDetailsScreen extends StatelessWidget {
  final String vendorId;
  final String fullName;
  final GeoPoint? location;

  const VendorDetailsScreen({
    Key? key,
    required this.vendorId,
    required this.fullName,
    this.location,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fullName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Products:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('vendors')
                    .doc(vendorId)
                    .collection('products')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final products = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      var product = products[index];
                      String productName = product['name'];
                      String category = product['category'];
                      double price = product['price'];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(productName),
                          subtitle: Text(
                            '$category: Rs. ${price.toStringAsFixed(2)} per kg/dozen',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const Text(
              'Location:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 400,
              height: 300,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(location!.latitude, location!.longitude),
                  zoom: 12,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('destinationLocation'),
                    icon: BitmapDescriptor.defaultMarker,
                    position: LatLng(location!.latitude, location!.longitude),
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
