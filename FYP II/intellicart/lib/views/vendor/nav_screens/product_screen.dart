import 'package:flutter/material.dart';
import 'package:intellicart/controllers/vendor_product_controller.dart';
import 'widgets/product_display_card.dart';

class ProductsScreen extends StatelessWidget {
  final VendorProductController _vendorProductController =
      VendorProductController();

  ProductsScreen({super.key});

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
        child: StreamBuilder<Map>(
          stream: _vendorProductController.getProductsinCategoryStream(),
          builder: (context, AsyncSnapshot<Map> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.data!.isEmpty) {
              return const Center(child: Text('No products added yet.'));
            } else {

              List<dynamic>? vegList = snapshot.data?['Vegetables'];
              List<dynamic>? fruitList = snapshot.data?['Fruits'];

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [ 
                    CustomCategoryCard(categoryName: 'Vegetables',displayList: vegList, image: 'assets/images/vegetables.jpg'),
                    CustomCategoryCard(categoryName: 'Fruits',displayList: fruitList, image: 'assets/images/fruits.jpg'),
                  ],
                ),
              );
            } //else
          },
        ),
      ),
    );
  }
}
