import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intellicart/views/customer/nav_screens/widgets/vendor_details_screen.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

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
        child: StreamBuilder<QuerySnapshot>(
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
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('vendors').doc(vendorId).get(),
                  builder: (context, vendorSnapshot) {
                    if (vendorSnapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(); 
                    }
                    if (vendorSnapshot.hasError) {
                      return const SizedBox(); 
                    }
                    String vendorName = vendorSnapshot.data!['fullName'];
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
                            return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirm Delete'),
                                  content: const Text('Are you sure you want to delete this rating?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(false); 
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(true); 
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
                        onDismissed: (direction) async {
                          if (direction == DismissDirection.endToStart) {
                            try {
                              await FirebaseFirestore.instance
                                  .collection('customers')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .collection('feedback')
                                  .doc(feedback.id)
                                  .delete();
                              await FirebaseFirestore.instance
                                  .collection('vendors')
                                  .doc(vendorId)
                                  .collection('feedback')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .delete();
                              _recalculateAverageRating(vendorId);
                            } catch (error) {
                              print('Failed to delete feedback: $error');
                            }
                          }
                        },
                        child: Column(
                          children: [
                            Container(
                              color: const Color.fromARGB(255, 200, 234, 199),  // Changed background color here
                              child: ListTile(
                                title: Text('VENDOR: $vendorName',
                                style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              ),),
                                subtitle: Text('Rating: $rating'),
                              ),
                            ),
                            const SizedBox(height: 8), 
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
        await FirebaseFirestore.instance.collection('vendors').doc(vendorId).update({
          'averageRating': 0.0,
        });
      }
    } catch (error) {
      print('Failed to recalculate average rating: $error');
    }
  }
}
