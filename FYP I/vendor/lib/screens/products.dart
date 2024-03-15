import 'package:flutter/material.dart';
import 'package:vendor/widgets/products_card.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    List<ProductCard> products = const [
      ProductCard(
        name: 'Apple',
        category: 'Fruits',
        price: 200,
        image: 'assets/images/apple.jpg',
        governmentSubsidy: 10,
      ),
      ProductCard(
        name: 'Banana',
        category: 'Fruits',
        price: 250,
        image: 'assets/images/banana.jpg',
        governmentSubsidy: 20,
      ),
      ProductCard(
        name: 'Orange',
        category: 'Fruits',
        price: 180,
        image: 'assets/images/orange.jpg',
        governmentSubsidy: 5,
      ),
      ProductCard(
        name: 'Tomato',
        category: 'Vegetables',
        price: 150,
        image: 'assets/images/tomato.jpg',
        governmentSubsidy: 20,
      ),
      ProductCard(
        name: 'Chilli',
        category: 'Vegetables',
        price: 80,
        image: 'assets/images/chilli.jpg',
        governmentSubsidy: 15,
      ),
    ];

    List<ProductCard> filteredProducts = products
        .where((product) =>
            selectedCategory == 'All' || selectedCategory == product.category)
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(selectedCategory),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedCategory,
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue!;
                });
              },
              items: ['All', 'Fruits', 'Vegetables']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          return filteredProducts[index];
        },
      ),
    );
  }
}