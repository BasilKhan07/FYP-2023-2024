import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EmojiItem extends StatefulWidget {
  final String emoji;
  final int value;
  final ValueChanged<int> onSelected;

  const EmojiItem({
    Key? key,
    required this.emoji,
    required this.value,
    required this.onSelected,
  }) : super(key: key);

  @override
  _EmojiItemState createState() => _EmojiItemState();
}

class _EmojiItemState extends State<EmojiItem> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isSelected = true;
        });
        widget.onSelected(widget.value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(_isSelected ? 1.5 : 1.0),
        child: Text(
          widget.emoji,
          style: const TextStyle(fontSize: 30, color: Colors.white), // Text color changed to white
        ),
      ),
    );
  }
}

class VendorDetailsScreen extends StatefulWidget {
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
  _VendorDetailsScreenState createState() => _VendorDetailsScreenState();
}

class _VendorDetailsScreenState extends State<VendorDetailsScreen> {
  bool isFavorite = false;
  int rating = 3;

  @override
  void initState() {
    super.initState();
    checkFavorite();
  }

  void checkFavorite() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String customerId = user.uid;
        DocumentSnapshot customerSnapshot =
            await FirebaseFirestore.instance.collection('customers').doc(customerId).get();

        List<dynamic> favorites = customerSnapshot.get('favorites') ?? [];

        setState(() {
          isFavorite = favorites.any((favorite) => favorite['vendorId'] == widget.vendorId);
        });
      }
    } catch (error) {
      print('Error checking favorite: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, //added due to screen pixel overflow caused by opening keyboard
      appBar: AppBar(
        title: Text(widget.fullName, style: const TextStyle(color: Colors.white)), // Text color changed to white
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              setState(() {
                isFavorite = !isFavorite;
              });
              toggleFavorite();
            },
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 6, 24, 8), // Background color changed
      ),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Products:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white), // Text color changed to white
              ),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('vendors')
                      .doc(widget.vendorId)
                      .collection('products')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white))); // Text color changed to white
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
                          color: const Color.fromARGB(255, 200, 234, 199),
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(productName.toUpperCase(), style: const TextStyle(color: Color.fromARGB(255, 17, 17, 17), fontWeight: FontWeight.bold,)), // Text color changed to white
                            subtitle: Text(
                              '$category: Rs. ${price.toStringAsFixed(2)} per kg/dozen',
                              style: const TextStyle(color: Color.fromARGB(255, 8, 8, 8)), // Text color changed to white
                            ),
                            // Background color changed
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16), // Add a gap after the product list
              const Text(
                'Location:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white), // Text color changed to white
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                child: SizedBox(
                  width: 400,
                  height: 300,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(widget.location!.latitude, widget.location!.longitude),
                      zoom: 12,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('destinationLocation'),
                        icon: BitmapDescriptor.defaultMarker,
                        position: LatLng(widget.location!.latitude, widget.location!.longitude),
                      ),
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16), // Add a gap after the map
              Center( // Center-align the button
                child: ElevatedButton(
                  onPressed: () {
                    _showFeedbackDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, 
                    backgroundColor: const Color.fromARGB(255, 3, 21, 36), // Text color changed
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12), // Button padding
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Button border radius
                    textStyle: const TextStyle(fontSize: 15), // Text style
                  ),
                  child: const Text('Leave Feedback'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void toggleFavorite() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String customerId = user.uid;
        DocumentSnapshot customerSnapshot =
            await FirebaseFirestore.instance.collection('customers').doc(customerId).get();

        List<dynamic> favorites = customerSnapshot.get('favorites') ?? [];
        bool alreadyFavorite = favorites.any((favorite) => favorite['vendorId'] == widget.vendorId);

        if (alreadyFavorite) {
          await FirebaseFirestore.instance.collection('customers').doc(customerId).update({
            'favorites': favorites.where((favorite) => favorite['vendorId'] != widget.vendorId).toList(),
          });
        } else {
          favorites.add({
            'vendorId': widget.vendorId,
            'fullName': widget.fullName,
            'location': widget.location,
          });
          await FirebaseFirestore.instance.collection('customers').doc(customerId).update({
            'favorites': favorites,
          });
        }

        setState(() {
          isFavorite = !alreadyFavorite;
        });
      }
    } catch (error) {
      print('Failed to toggle favorite: $error');
    }
  }

  void _showFeedbackDialog(BuildContext context) async {
    try {
      String feedbackText = ''; // Define feedbackText variable here
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String customerId = user.uid;
        QuerySnapshot feedbackSnapshot = await FirebaseFirestore.instance
            .collection('customers')
            .doc(customerId)
            .collection('feedback')
            .where('vendorId', isEqualTo: widget.vendorId)
            .get();

        if (feedbackSnapshot.docs.isNotEmpty) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Feedback already exists', style: TextStyle(color: Colors.white)), // Text color changed to white
                content: const Text(
                    'You have already left feedback for this vendor. Please delete your existing feedback before leaving a new one.',
                    style: TextStyle(color: Colors.white)), // Text color changed to white
                backgroundColor: const Color.fromARGB(255, 6, 24, 8), // Background color changed
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK', style: TextStyle(color: Colors.white)), // Text color changed to white
                  ),
                ],
              );
            },
          );
        } else {
          // Show the feedback dialog
          // ignore: use_build_context_synchronously
          showDialog(
  context: context,
  builder: (BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Emoji buttons representing different levels of satisfaction
                    EmojiItem(
                      emoji: '😢',
                      value: 1,
                      onSelected: (value) {
                        setState(() {
                          rating = value;
                        });
                      },
                    ),
                    EmojiItem(
                      emoji: '😔',
                      value: 2,
                      onSelected: (value) {
                        setState(() {
                          rating = value;
                        });
                      },
                    ),
                    EmojiItem(
                      emoji: '😐',
                      value: 3,
                      onSelected: (value) {
                        setState(() {
                          rating = value;
                        });
                      },
                    ),
                    EmojiItem(
                      emoji: '😊',
                      value: 4,
                      onSelected: (value) {
                        setState(() {
                          rating = value;
                        });
                      },
                    ),
                    EmojiItem(
                      emoji: '😍',
                      value: 5,
                      onSelected: (value) {
                        setState(() {
                          rating = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                TextField(
                  decoration: const InputDecoration(labelText: 'Feedback', labelStyle: TextStyle(color: Color.fromARGB(255, 5, 4, 4))), // Text color changed to white
                  style: const TextStyle(color: Color.fromARGB(255, 12, 10, 10)), // Text color changed to white
                  onChanged: (value) {
                    feedbackText = value;
                  },
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel', style: TextStyle(color: Color.fromARGB(255, 16, 13, 13))), // Text color changed to white
                    ),
                    TextButton(
                      onPressed: () {
                        _submitFeedback(customerId, rating, feedbackText);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Submit', style: TextStyle(color: Color.fromARGB(255, 7, 6, 6))), // Text color changed to white
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  },
);

        }
      }
    } catch (error) {
      print('Error checking feedback: $error');
    }
  }

  void _submitFeedback(String customerId, int rating, String feedbackText) async {
    try {
      DocumentReference feedbackRefVendor = FirebaseFirestore.instance
          .collection('vendors')
          .doc(widget.vendorId)
          .collection('feedback')
          .doc(customerId); // Save feedback ID in vendor collection as customer ID

      DocumentReference feedbackRefCustomer = FirebaseFirestore.instance
          .collection('customers')
          .doc(customerId)
          .collection('feedback')
          .doc(widget.vendorId); // Save feedback ID in customer collection as vendor ID

      // Save feedback in vendor's collection along with feedback ID
      await feedbackRefVendor.set({
        'customerId': customerId,
        'rating': rating,
        'feedbackText': feedbackText,
        'timestamp': Timestamp.now(),
        'feedbackId': feedbackRefVendor.id, // Save the feedback ID from the vendor's collection
      });

      // Save feedback in customer's collection
      await feedbackRefCustomer.set({
        'vendorId': widget.vendorId,
        'rating': rating,
        'feedbackText': feedbackText,
        'timestamp': Timestamp.now(),
      });

      // Recalculate average rating and update it in the vendor collection
      _recalculateAverageRating(widget.vendorId);
    } catch (error) {
      print('Failed to submit feedback: $error');
    }
  }

  void _deleteFeedback(String feedbackId) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String customerId = user.uid;
        await FirebaseFirestore.instance.collection('customers').doc(customerId).collection('feedback').doc(feedbackId).delete();

        // After deleting the feedback, recalculate the average rating
        _recalculateAverageRating(widget.vendorId);
      }
    } catch (error) {
      print('Failed to delete feedback: $error');
    }
  }

  Future<void> _recalculateAverageRating(String vendorId) async {
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
