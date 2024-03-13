import 'package:flutter/material.dart';
import 'package:vendor/models/items.dart';
import 'package:vendor/widgets/item_card.dart';

class CategoryCard extends StatelessWidget {
  final String name;
  final String image;
  final List<Item> items;

  const CategoryCard({
    super.key,
    required this.name,
    required this.image,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset(
            image,
            height: 150.0,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Column(
            children: items.map((item) => ItemCard(item: item)).toList(),
          ),
        ],
      ),
    );
  }
}
