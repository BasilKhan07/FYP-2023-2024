import 'package:flutter/material.dart';

class FeedbackScreen extends StatelessWidget {
  final List<Map<String, dynamic>> feedbackList = [
    {
      'cartName': 'Cart 3',
      'sellerName': 'Baadshah Bhai',
      'rating': 4,
      'comments': 'Great service and quality products!',
    },
    {
      'cartName': 'Cart 2',
      'sellerName': 'Ali qadir',
      'rating': 4.7,
      'comments': 'Good variety but can improve on pricing.',
    },
  ];

  FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (feedbackList.isEmpty)
          ? const Center(child: Text('No feedback given yet.'))
          : ListView.builder(
              itemCount: feedbackList.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text('Seller: ${feedbackList[index]['sellerName']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Rating: ${feedbackList[index]['rating']}'),
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                          ],
                        ),
                        Text('Comments: ${feedbackList[index]['comments']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
