import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({Key? key}) : super(key: key);

  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late TextEditingController _productNameController;
  late TextEditingController _quantityController;
  late String _selectedCategory = '';
  late List<String> _categories = ['Fruit', 'Vegetable', ''];
  late Map<String, double> _productPrices = {};
  late DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _productNameController = TextEditingController();
    _quantityController = TextEditingController();
    _loadProductPrices();
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadProductPrices() async {
    final productsSnapshot =
        await FirebaseFirestore.instance.collectionGroup('products').get();
    productsSnapshot.docs.forEach((productDoc) {
      final data = productDoc.data() as Map<String, dynamic>;
      _productPrices[productDoc.id] = data['price'];
    });
  }

  Future<void> _addSale() async {
    final vendorId =
        _auth.currentUser!.uid; // Replace this with actual vendor ID
    final productName = _productNameController.text;
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    if (_productPrices.containsKey(productName)) {
    final totalPrice = _productPrices[productName]! * quantity;
    await FirebaseFirestore.instance
        .collection('vendors')
        .doc(vendorId)
        .collection('sales')
        .doc(
            '${_selectedDate.year}_${_selectedDate.month}_${_selectedDate.day}')
        .set({
      'productName': productName,
      'category': _selectedCategory,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'date': _selectedDate,
    }, SetOptions(merge: true));
    // Rest of your code to add the sale
  } else {
    // Handle the case when product price is not found
    // For example, show an error message or set a default price
    print('Product price for $productName not found.');
  }

    

    // Clear text controllers after adding the sale
    _productNameController.clear();
    _quantityController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Sale',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          TextField(
            controller: _productNameController,
            decoration: InputDecoration(labelText: 'Product Name'),
          ),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            onChanged: (String? value) {
              setState(() {
                _selectedCategory = value!;
              });
            },
            items: _categories.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            decoration: InputDecoration(labelText: 'Category'),
          ),
          TextField(
            controller: _quantityController,
            decoration: InputDecoration(labelText: 'Quantity'),
            keyboardType: TextInputType.number,
          ),
          ElevatedButton(
            onPressed: _addSale,
            child: Text('Add Sale'),
          ),
          SizedBox(height: 20),
          Text(
            'Sales List',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('vendors')
                  .doc('your_vendor_id_here')
                  .collection('sales')
                  .where('date',
                      isGreaterThan: DateTime.now().subtract(Duration(days: 7)))
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  final sales = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: sales.length,
                    itemBuilder: (context, index) {
                      final sale = sales[index];
                      return ListTile(
                        title: Text('Product: ${sale['productName']}'),
                        subtitle: Text(
                            'Category: ${sale['category']}, Quantity: ${sale['quantity']}, Total Price: ${sale['totalPrice']}'),
                        trailing: Text('Date: ${sale['date'].toDate()}'),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
