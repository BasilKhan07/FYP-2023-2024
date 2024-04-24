import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import "package:intellicart/controllers/vendor_dashboard_controller.dart";

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final VendorDashboardController VDController = VendorDashboardController();
  late String _vendorId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;  //user.uid
  List<DocumentSnapshot>? _products;
  int _quantity = 1;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  Future<List<dynamic>> getData() async {
    return await VDController.getNoOfCategories_getNoOfFruitsandVeg();
  }

  @override
  Widget build(BuildContext context) {
    List<String> headers = ['No of Categories', 'No of Fruits', 'No of Vegetables'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Vendor Dashboard'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            // Build a column with a ListTile for each value in the list
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final dynamic value = snapshot.data![index];
                final String header = headers[index % headers.length]; // Get header using index

                // return Column(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     Padding(
                //       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                //       child: Text(
                //         header,
                //         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                //       ),
                //     ),
                //     ListTile(
                //       title: Text(value.toString()),
                //     ),
                //   ],
                // );
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Center(
                      child: Text(
                        header,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Center(
                          child: Text(value.toString(),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );  
          } // else ends
        },
      ),
    );
  }
}