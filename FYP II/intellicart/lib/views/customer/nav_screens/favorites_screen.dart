import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intellicart/views/customer/nav_screens/widgets/vendor_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 6, 24, 8), 
              Color.fromARGB(255, 109, 161, 121),
            ],
          ),
        ),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('customers').doc(FirebaseAuth.instance.currentUser?.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            List<dynamic> favoriteVendors = snapshot.data!.get('favorites') ?? [];

            if (favoriteVendors.isEmpty) {
              return Center(child: Text('No favorites yet.'));
            }

            return ListView.builder(
              itemCount: favoriteVendors.length,
              itemBuilder: (context, index) {
                var vendor = favoriteVendors[index];
                String vendorId = vendor['vendorId'];
                String fullName = vendor['fullName'];
                GeoPoint? location = vendor['location'];

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VendorDetailsScreen(
                          vendorId: vendorId,
                          fullName: fullName,
                          location: location,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.all(10.0),
                    child: Container(
                      color: const Color.fromARGB(255, 200, 234, 199), // Changed background color here
                      child: ListTile(
                        title: Text('Vendor: $fullName'),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
