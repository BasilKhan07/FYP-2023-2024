import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intellicart/views/customer/nav_screens/widgets/vendor_details_screen.dart';

// Import necessary packages

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
            return const Center(child: CircularProgressIndicator());
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
                    return const SizedBox(); // Return an empty container while waiting for the vendor data
                  }
                  if (vendorSnapshot.hasError) {
                    return const SizedBox(); // Return an empty container if there's an error
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
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          // Confirm delete
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirm Delete'),
                                content: const Text('Are you sure you want to delete this rating?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false); // Dismiss the dialog without deleting
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true); // Dismiss the dialog and delete
                                    },
                                    child: const Text('Delete'),
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
                              .delete()
                              .then((value) {
                            // Delete feedback from vendor's collection
                            FirebaseFirestore.instance
                                .collection('vendors')
                                .doc(vendorId)
                                .collection('feedback')
                                .doc(feedback.id)
                                .delete()
                                .then((value) {
                              // After deleting the feedback, recalculate the average rating
                              _recalculateAverageRating(vendorId);
                            });
                          });
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
                          const SizedBox(height: 8), // Add white gap between each rating
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

  void _recalculateAverageRating(String vendorId) async {
    try {
      QuerySnapshot feedbackSnapshot = await FirebaseFirestore.instance.collection('vendors').doc(vendorId).collection('feedback').get();
      int totalRating = 0;
      int numberOfFeedbacks = feedbackSnapshot.docs.length;

      if (numberOfFeedbacks > 0) {
        for (QueryDocumentSnapshot feedbackDoc in feedbackSnapshot.docs) {
          int rating = feedbackDoc['rating'] as int;
          totalRating += rating;
        }

        double averageRating = totalRating / numberOfFeedbacks;

        await FirebaseFirestore.instance.collection('vendors').doc(vendorId).update({
          'averageRating': averageRating,
        });
      } else {
        // If there are no feedbacks, set averageRating to 0.0
        await FirebaseFirestore.instance.collection('vendors').doc(vendorId).update({
          'averageRating': 0.0,
        });
      }
    } catch (error) {
      print('Failed to recalculate average rating: $error');
    }
  }
}
