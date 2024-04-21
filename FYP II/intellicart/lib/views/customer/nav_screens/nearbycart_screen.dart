import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intellicart/controllers/customer_vendorlist_controller.dart';
import 'package:intellicart/views/customer/nav_screens/widgets/vendor_details_screen.dart';
import 'package:intellicart/api/fetch_govt_price.dart';

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({Key? key}) : super(key: key);

  @override
  _NearbyScreenState createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  final CustomerVendorController _vendorController =
      CustomerVendorController();
  final PriceFetcher priceFetcher = PriceFetcher();
  Map<String, dynamic>? priceData;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getLocationPermission();
    callFetcher();
  }

  void _getLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Request location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Get current position
    _currentPosition = await Geolocator.getCurrentPosition();
    setState(() {});
  }

  void callFetcher() async {
    Map<String, dynamic>? retrievedPriceData =
        await priceFetcher.fetchDataAndStorePrices();
    setState(() {
      priceData = retrievedPriceData;
    });
  }

  Stream<QuerySnapshot<Object>> _getVendors() {
    return _vendorController.getVendors();
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double radius = 6371; // Earth's radius in kilometers
    double dLat = _degToRad(lat2 - lat1);
    double dLon = _degToRad(lon2 - lon1);
    double a = Math.pow(Math.sin(dLat / 2), 2) +
        Math.cos(_degToRad(lat1)) *
            Math.cos(_degToRad(lat2)) *
            Math.pow(Math.sin(dLon / 2), 2);
    double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    double distance = radius * c;
    return distance;
  }

  double _degToRad(double deg) {
    return deg * (Math.pi / 180);
  }

  void _updateLocation() async {
    _getLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       
      body: StreamBuilder<QuerySnapshot>(
        stream: _getVendors(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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

              if (_currentPosition != null && vendorLocation != null) {
                double distance = _calculateDistance(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                    vendorLocation.latitude,
                    vendorLocation.longitude);
                if (distance > 1) {
                  // Skip vendors outside the 1 km radius
                  return Container();
                }
              }

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
                    title: Text('vendor: $fullName'),
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
                            int? govtPrice =
                                priceData?[productName] as int? ?? -1;
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
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _updateLocation,
        tooltip: 'Update Location',
        child: Icon(Icons.location_on),
      ),
    );
  }
}
