import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
      appBar: AppBar(
        title: Text(widget.fullName),
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Products:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
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
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(productName),
                          subtitle: Text(
                            '$category: Rs. ${price.toStringAsFixed(2)} per kg/dozen',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const Text(
              'Location:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
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
            ElevatedButton(
              onPressed: () {
                _showFeedbackDialog(context);
              },
              child: Text('Leave Feedback'),
            ),
          ],
        ),
      ),
    );
  }

  void toggleFavorite() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String customerId = user.uid;
        DocumentSnapshot customerSnapshot = await FirebaseFirestore.instance.collection('customers').doc(customerId).get();

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

void _showFeedbackDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      int rating = 0;
      String feedbackText = '';
      return Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    for (int i = 1; i <= 5; i++)
      InkWell(
        onTap: () {
          setState(() {
            rating = i;
          });
        },
        child: Icon(
          i <= rating ? Icons.star : Icons.star_border,
          color: i <= rating ? Colors.yellow : Colors.grey,
        ),
      ),
  ],
),

              SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(labelText: 'Feedback'),
                onChanged: (value) {
                  feedbackText = value;
                },
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      _submitFeedback(rating, feedbackText);
                      Navigator.of(context).pop();
                    },
                    child: Text('Submit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}







  void _submitFeedback(int rating, String feedbackText) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String customerId = user.uid;
        await FirebaseFirestore.instance.collection('customers').doc(customerId).collection('feedback').add({
          'vendorId': widget.vendorId,
          'rating': rating,
          'feedbackText': feedbackText,
          'timestamp': Timestamp.now(),
        });
      }
    } catch (error) {
      print('Failed to submit feedback: $error');
    }
  }
}

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('customers').doc(FirebaseAuth.instance.currentUser!.uid).collection('feedback').snapshots(),
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
              String feedbackText = feedback['feedbackText'];
              return ListTile(
                title: Text('Rating: $rating'),
                subtitle: Text(feedbackText),
              );
            },
          );
        },
      ),
    );
  }
}
