import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intellicart/controllers/customer_vendorlist_controller.dart';
import 'package:intellicart/views/customer/nav_screens/widgets/vendor_details_screen.dart';
import 'package:intellicart/api/fetch_govt_price.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final CustomerVendorController _vendorController = CustomerVendorController();
  final PriceFetcher priceFetcher = PriceFetcher();
  Map<String, dynamic>? priceData;

  void callFetcher() async {
    Map<String, dynamic>? retrievedPriceData = await priceFetcher.fetchDataAndStorePrices();
    setState(() {
      priceData = retrievedPriceData;
    });
  }

  @override
  void initState() {
    super.initState();
    callFetcher();
  }

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
            String vendorId = vendor.id; // Get vendor ID

            return InkWell(
              onTap: () {
                // Navigate to vendor details screen on tap
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VendorDetailsScreen(
                      vendorId: vendorId, // Pass vendor ID
                      fullName: fullName,
                      location: vendorLocation,
                    ),
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.all(10.0),
                child: ListTile(
                  title: Text('Vendor: $fullName'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('customers')
                            .doc(vendorId) // Use vendor ID to fetch feedback
                            .collection('feedback')
                            .snapshots(),
                        builder: (context, feedbackSnapshot) {
                          if (feedbackSnapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (feedbackSnapshot.hasError) {
                            return Text('Error: ${feedbackSnapshot.error}');
                          }

                          final feedbackList = feedbackSnapshot.data!.docs;
                          if (feedbackList.isEmpty) {
                            return Text('Avg Rating: No ratings available');
                          }

                          int totalRating = 1;
                          int numberOfRatings = 0;
                          for (var feedback in feedbackList) {
                            int rating = feedback['rating'];
                            totalRating += rating;
                            numberOfRatings++;
                          }
                          double averageRating = totalRating / numberOfRatings;
                          return Text('Avg Rating: $averageRating');
                        },
                      ),
                      SizedBox(height: 8),
                      StreamBuilder<QuerySnapshot>(
                        stream: vendor.reference.collection('products').snapshots(),
                        builder: (context, productSnapshot) {
                          if (productSnapshot.connectionState == ConnectionState.waiting) {
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
                              int? govtPrice = priceData?[productName] as int? ?? -1;
                              String category = product['category'];
                              double price = product['price'];

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  '$productName - $category: Rs. ${price.toStringAsFixed(2)} per kg / dozen  Govt_price : $govtPrice',
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
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
