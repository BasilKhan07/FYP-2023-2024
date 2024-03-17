import 'package:flutter/material.dart';
import 'package:vendor/models/items.dart';
import 'package:vendor/widgets/category_card.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CategoryCard(
              name: 'Fruits',
              image: 'assets/images/fruits.jpg',
              items: [
                Item(name: 'Apple', price: 'Rs. 200 per kg'),
                Item(name: 'Banana', price: 'Rs. 250 per kg'),
                Item(name: 'Orange', price: 'Rs. 180 per kg'),
              ],
            ),
            CategoryCard(
              name: 'Vegetables',
              image: 'assets/images/vegetables.jpg',
              items: [
                Item(name: 'Tomato', price: 'Rs. 150 per kg'),
                Item(name: 'Chilli', price: 'Rs. 80 per kg'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}