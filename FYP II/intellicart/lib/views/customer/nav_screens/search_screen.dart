import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intellicart/controllers/customer_vendorlist_controller.dart';
import 'package:intellicart/views/customer/nav_screens/widgets/vendor_details_screen.dart';

class SearchScreen extends StatelessWidget {
  final CustomerVendorController _vendorController = CustomerVendorController();

  SearchScreen({Key? key});

  Stream<QuerySnapshot<Object>> _getVendors() {
    return _vendorController.getVendors();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getVendors(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final vendors = snapshot.data!.docs;

        return ListView.builder(
          itemCount: vendors.length,
          itemBuilder: (context, index) {
            var vendor = vendors[index];
            String fullName = vendor['fullName'];
            GeoPoint? vendorLocation = vendor['location']; // Fetch vendor location

            return InkWell(
              onTap: () {
                // Navigate to vendor details screen on tap
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VendorDetailsScreen(
                      vendorId: vendor.id,
                      fullName: fullName,
                      location: vendorLocation,
                    ),
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.all(10.0),
                child: ListTile(
                  title: Text(fullName),
                  subtitle: StreamBuilder<QuerySnapshot>(
                    stream: vendor.reference.collection('products').snapshots(),
                    builder: (context, productSnapshot) {
                      if (productSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (productSnapshot.hasError) {
                        return Text('Error: ${productSnapshot.error}');
                      }

                      final products = productSnapshot.data!.docs;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: products.map((product) {
                          String productName = product['name'];
                          String category = product['category'];
                          double price = product['price'];

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              '$productName - $category: Rs. ${price.toStringAsFixed(2)} per kg / dozen',
                              style: const TextStyle(fontSize: 16.0),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
