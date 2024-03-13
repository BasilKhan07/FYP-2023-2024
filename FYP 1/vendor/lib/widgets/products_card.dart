import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String name;
  final String category;
  final double price;
  final String image;
  final double governmentSubsidy;

  const ProductCard({super.key, 
    required this.name,
    required this.category,
    required this.price,
    required this.image,
    required this.governmentSubsidy,
  });

  @override
  Widget build(BuildContext context) {
    double discountedPrice = price - governmentSubsidy;

    return Card(
      elevation: 10,
      margin: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset(
            image,
            height: 100.0,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            title: Text('Government Price: Rs. $price per kg'),
            subtitle: Text('Selling Price: Rs. $discountedPrice per kg'),
          ),
        ],
      ),
    );
  }
}