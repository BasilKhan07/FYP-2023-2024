import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intellicart/views/customer/nav_screens/widgets/vendor_details_screen.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('customers')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('feedback')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final feedbackList = snapshot.data!.docs;
          return ListView.builder(
            itemCount: feedbackList.length,
            itemBuilder: (context, index) {
              var feedback = feedbackList[index];
              int rating = feedback['rating'];
              String vendorId = feedback['vendorId'];
              // Fetch vendor details
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('vendors').doc(vendorId).get(),
                builder: (context, vendorSnapshot) {
                  if (vendorSnapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(); // Return an empty container while waiting for the vendor data
                  }
                  if (vendorSnapshot.hasError) {
                    return SizedBox(); // Return an empty container if there's an error
                  }
                  String vendorName = vendorSnapshot.data!['fullName'];
                  // Display vendor details and rating
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VendorDetailsScreen(
                            vendorId: vendorId,
                            fullName: vendorName,
                            location: vendorSnapshot.data!['location'],
                          ),
                        ),
                      );
                    },
                    child: Dismissible(
                      key: UniqueKey(),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 16),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          // Confirm delete
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirm Delete'),
                                content: Text('Are you sure you want to delete this rating?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false); // Dismiss the dialog without deleting
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true); // Dismiss the dialog and delete
                                    },
                                    child: Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                        return false;
                      },
                      onDismissed: (direction) {
                        if (direction == DismissDirection.endToStart) {
                          // Delete rating from database
                          FirebaseFirestore.instance
                              .collection('customers')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .collection('feedback')
                              .doc(feedback.id)
                              .delete();
                        }
                      },
                      child: Column(
                        children: [
                          Container(
                            color: Colors.grey[300], // Set the background color to gray
                            child: ListTile(
                              title: Text('Vendor: $vendorName'),
                              subtitle: Text('Rating: $rating'),
                            ),
                          ),
                          SizedBox(height: 8), // Add white gap between each rating
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
