import 'package:flutter/material.dart';
import 'package:intellicart/controllers/vendor_product_controller.dart';

class ProductsScreen extends StatelessWidget {
  final VendorProductController _vendorProductController =
      VendorProductController();

  ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<Map>(
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

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: Color.fromARGB(255, 135, 218, 63).withOpacity(1),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Vegetables',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      vegList != null && vegList.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: vegList.length,
                          itemBuilder: (context, index) {
                            String productPrice = vegList[index]['price'].toStringAsFixed(2);
                            String productName = vegList[index]['name'];
                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 173, 217, 107).withOpacity(0.9), // Highlight color
                                borderRadius: BorderRadius.circular(8.0), // Rounded corners
                              ),
                              child: ListTile(
                                title: Text('$productName',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text('Price: Rs. $productPrice per kg / dozen'),
                              ),
                            );
                          },
                        )
                      : const ListTile(
                          title: Text('No Vegetables listed for Sale'),
                        ),
                    ],
                  ),
                ),
                Card(
                  color: Color.fromARGB(255, 135, 218, 63).withOpacity(1),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Fruits',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      fruitList != null && fruitList.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: fruitList.length,
                          itemBuilder: (context, index) {
                            String productPrice = fruitList[index]['price'].toStringAsFixed(2);
                            String productName = fruitList[index]['name'];
                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 173, 217, 107).withOpacity(0.9), // Highlight color
                                borderRadius: BorderRadius.circular(8.0), // Rounded corners
                              ),
                              child: ListTile(
                                title: Text('$productName',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text('Price: Rs. $productPrice per kg / dozen'),
                              ),
                            );
                          },
                        )
                      : const ListTile(
                          title: Text('No Fruits listed for Sale'),
                        ),
                    ],
                  ),
                ),
              ],
            );
          } //else
        },
      ),
    );
  }
}
