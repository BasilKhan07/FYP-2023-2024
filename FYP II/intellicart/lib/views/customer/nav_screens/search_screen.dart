import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intellicart/controllers/customer_vendorlist_controller.dart';
import 'package:intellicart/views/customer/nav_screens/widgets/vendor_details_screen.dart';
import 'package:intellicart/api/fetch_govt_price.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final CustomerVendorController _vendorController = CustomerVendorController();
  final PriceFetcher priceFetcher = PriceFetcher();
  Map<String, dynamic>? priceData;
  Map<String, dynamic> myMap = {
    'apple_blotch': 0,
    'apple_healthy': 0,
    'apple_rotten': 0,
    'apple_scab': 0,
    'banana_firm': 0,
    'banana_heavilybruised': 0,
    'banana_slightlybruised': 0,
    'greenchilli_damaged': 0,
    'greenchilli_dried': 0,
    'greenchilli_old': 0,
    'greenchilli_ripe': 0,
    'orange_greening': 0,
    'orange_healthy': 0,
    'orange_rotten': 0,
    'tomato_old': 0,
    'tomato_ripe': 0,
    'tomato_rotten': 0,
    'tomato_unripe': 0
  };

  final TextEditingController _searchController = TextEditingController();

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

  Future<Map<String, dynamic>> _getVendorQuality(String vendorId) async {
    print("In quality function");
    print(vendorId);
    DateTime now = DateTime.now();
    String formattedDate = '${now.year}-${now.month}-${now.day}';
    final vendorDoc = await FirebaseFirestore.instance.collection('vendors').doc(vendorId).get();
    print('vendor DOCCCCCCCCCCCCCC');
    final videoResultsDoc = await vendorDoc.reference.collection('video_results').doc(formattedDate).get();
    print(videoResultsDoc.data());
    return videoResultsDoc.data() as Map<String, dynamic>? ?? {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 6, 24, 8), 
              Color.fromARGB(255, 109, 161, 121),
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search for Fruit/Vegetable',
                  hintStyle: TextStyle(color: Color.fromARGB(255, 181, 184, 185)), // Change hint text color to white
                  prefixIcon: Icon(Icons.search, color: Color.fromARGB(255, 181, 184, 185),),
                ),
                style: TextStyle(color: Color.fromARGB(255, 181, 184, 185), fontSize: 16), // Change text color to white
                onChanged: (value) {
                  setState(() {}); // Trigger rebuild when the text changes
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
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
                      String vendorId = vendor.id; // Get vendor ID

                      return StreamBuilder<QuerySnapshot>(
                        stream: vendor.reference.collection('products').snapshots(),
                        builder: (context, productSnapshot) {
                          if (productSnapshot.connectionState == ConnectionState.waiting) {
                            return const SizedBox(); // Return an empty SizedBox while waiting for products snapshot
                          }
                          if (productSnapshot.hasError) {
                            return Text('Error: ${productSnapshot.error}');
                          }

                          final products = productSnapshot.data!.docs;

                          // Filter products based on search query
                          List<DocumentSnapshot> filteredProducts = products.where((product) {
                            String productName = product['name'].toString().toLowerCase();
                            String searchQuery = _searchController.text.toLowerCase();
                            return productName.contains(searchQuery);
                          }).toList();

                          // Only build the vendor card if there are matching products
                          if (filteredProducts.isNotEmpty) {
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
                                color: const Color.fromARGB(255, 200, 234, 199), // Light green
                                child: ListTile(
                                  title: Text(
                                    'Vendor: ${fullName.toUpperCase()}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection('vendors')
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
                                            return const Text('Avg Rating: No ratings available',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            );
                                          }

                                          int totalRating = 0;
                                          for (var feedback in feedbackList) {
                                            int rating = feedback['rating'];
                                            totalRating += rating;
                                          }
                                          double averageRating = totalRating / feedbackList.length;
                                          return Text('Avg Rating: ${averageRating.toStringAsFixed(2)}');
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      FutureBuilder<Map<String, dynamic>>(
                                        future: _getVendorQuality(vendorId),
                                        builder: (context, priceSnapshot) {
                                          if (priceSnapshot.connectionState == ConnectionState.waiting) {
                                            return const CircularProgressIndicator();
                                          }
                                          if (priceSnapshot.hasError) {
                                            return Text('Error: ${priceSnapshot.error}');
                                          }

                                          final vendorQuality = priceSnapshot.data;

                                          if (vendorQuality == null) {
                                            // Handle the case where data is not available
                                            return const Text('No data available');
                                          }
                                          myMap.clear(); // Clear myMap before updating it
                                          myMap.addAll(vendorQuality);

                                          // Update myMap directly
                                          for (var entry in vendorQuality.entries) {
                                            if (myMap.containsKey(entry.key)) {
                                              myMap[entry.key] = entry.value;
                                            }
                                            else{
                                            }
                                          }

                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: filteredProducts.map((product) {
                                              String productName = product['name'];
                                              int? govtPrice = priceData?[productName] as int? ?? -1;
                                              double price = product['price'];

                                              String additionalInfo = '';
                                              // Check the product name and add additional info accordingly
                                              if (productName.toLowerCase() == 'apple') {
                                                additionalInfo = 'Blotch: ${myMap['apple_blotch'] ?? 0} %\n';
                                                additionalInfo += 'Healthy: ${myMap['apple_healthy'] ?? 0} %\n';
                                                additionalInfo += 'Rotten: ${myMap['apple_rotten'] ?? 0} %\n';
                                                additionalInfo += 'Scab: ${myMap['apple_scab'] ?? 0} %\n';
                                              } else if (productName.toLowerCase() == 'green chilli') {
                                                additionalInfo = 'Damaged: ${myMap['greenchilli_damaged'] ?? 0 } %';
                                                additionalInfo += '\nDried: ${myMap['greenchilli_dried'] ?? 0} %';
                                                additionalInfo += '\nOld: ${myMap['greenchilli_old'] ?? 0 } %';
                                                additionalInfo += '\nRipe: ${myMap['greenchilli_ripe' ]?? 0} %';
                                              } else if (productName.toLowerCase() == 'banana') {
                                                additionalInfo = 'Firm: ${myMap['banana_firm'] ?? 0} %';
                                                additionalInfo += '\nHeavily bruised: ${myMap['banana_heavilybruised'] ?? 0} %';
                                                additionalInfo += '\nSlightly bruised: ${myMap['banana_slightlybruised'] ?? 0} %';
                                              } else if (productName.toLowerCase() == 'orange') {
                                                additionalInfo = 'Greening: ${myMap['orange_greening'] ?? 0} %';
                                                additionalInfo += '\nHealthy: ${myMap['orange_healthy'] ?? 0} %';
                                                additionalInfo += '\nRotten: ${myMap['orange_rotten'] ?? 0} %';
                                              } else if (productName.toLowerCase() == 'tomato') {
                                                additionalInfo = 'Old: ${myMap['tomato_old']?? 0} %';
                                                additionalInfo += '\nRipe: ${myMap['tomato_ripe']?? 0} %';
                                                additionalInfo += '\nRotten: ${myMap['tomato_rotten'] ?? 0} %';
                                                additionalInfo += '\nUnripe: ${myMap['tomato_unripe'] ?? 0} %';
                                              }
                                              return Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                                child: Text(
                                                '${productName.toUpperCase()}: Rs. ${price.toStringAsFixed(2)} per kg / dozen \nGovt_price : $govtPrice \n$additionalInfo',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                                                                )
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
                          } else {
                            return const SizedBox(); // Return an empty SizedBox if there are no matching products
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
