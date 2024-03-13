import 'package:flutter/material.dart';
import 'dart:math';

class CartDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> cart;

  const CartDetailsScreen({super.key, required this.cart});

  @override
  _CartDetailsScreenState createState() => _CartDetailsScreenState();
}

class _CartDetailsScreenState extends State<CartDetailsScreen> {
  TextEditingController feedbackController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cart['name']} Details'),
        backgroundColor: Colors.lightGreenAccent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Rating: ${widget.cart['rating']}'),
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                  ],
                ),
                Text('Location: ${widget.cart['location']}'),
                Text('Seller: ${widget.cart['sellerName']}'),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.cart['fruits'].length,
              itemBuilder: (context, index) {
                String fruit = widget.cart['fruits'][index];
                int sellingPrice = widget.cart['prices'][index];
                int governmentPrice =
                    widget.cart['prices'][index] - Random().nextInt(20) + 5;

                return Card(
                  elevation: 5,
                  child: ListTile(
                    title: Text(fruit),
                    leading: Image(
                      image: AssetImage('assets/images/${fruit.toLowerCase()}.jpg'),
                      height: 40,
                      width: 40,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Selling Price: Rs. $sellingPrice'),
                        Text('Government Price: Rs. $governmentPrice'),
                        Text(
                            'Difference: Rs. ${(governmentPrice - sellingPrice).abs()}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/map.jpeg',
                ),
              ],
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: feedbackController,
                decoration: const InputDecoration(
                  labelText: 'Provide feedback',
                ),
                maxLines: 3,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Feedback Submitted'),
                    content: const Text('Thank you for your feedback!'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Text('Submit Feedback'),
          ),
        ],
      ),
    );
  }
}
