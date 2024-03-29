import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intellicart/controllers/vendor_product_controller.dart';

class ProductsScreen extends StatelessWidget {
  final VendorProductController _vendorProductController =
      VendorProductController();

  ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _vendorProductController.getProductsStream(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No products added yet.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var productData =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;

                String productName = productData['name'];
                String productCategory = productData['category'];
                double productPrice = productData['price'];

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(
                      productName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Category: $productCategory',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Price: Rs. ${productPrice.toStringAsFixed(2)} per kg / dozen',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    onTap: () {},
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
