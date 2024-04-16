import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({Key? key}) : super(key: key);

  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  late String _vendorId;
  List<DocumentSnapshot>? _products;
  String _selectedProductId = '';
  int _quantity = 1;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _getVendorId();
  }

  Future<void> _getVendorId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot vendorDoc = await FirebaseFirestore.instance
          .collection('vendors')
          .doc(user.uid)
          .get();

      setState(() {
        _vendorId = vendorDoc.id;
      });

      _fetchProducts();
    } else {
      // Handle user not signed in
      // Redirect to sign-in screen or show error message
    }
  }

  Future<void> _fetchProducts() async {
    try {
      QuerySnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('vendors')
          .doc(_vendorId)
          .collection('products')
          .get();

      setState(() {
        _products = productSnapshot.docs;
        if (_products!.isNotEmpty) {
          _selectedProductId = _products!.first.id;
        }
      });
    } catch (e) {
      print('Error fetching products: $e');
      // Handle error
    }
  }

  double _calculateTotalCost(double price) {
    return price * _quantity;
  }

  Future<void> _addSale() async {
    try {
      // Get the current date
      DateTime now = DateTime.now();
      String formattedDate = '${now.year}-${now.month}-${now.day}';

      // Create a reference to the sales document for the current date
      DocumentReference salesRef = FirebaseFirestore.instance
          .collection('vendors')
          .doc(_vendorId)
          .collection('sales')
          .doc(formattedDate);

      // Use a transaction to update the sales document atomically
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot salesDoc = await transaction.get(salesRef);

        // Calculate the total cost for the new sale
        double productPrice = _products!
            .firstWhere((product) => product.id == _selectedProductId)['price'];
        double totalCost = _calculateTotalCost(productPrice);

        // Update the sales data with the new sale
        if (salesDoc.exists) {
          // If the document already exists, update the existing data
          Map<String, dynamic> data = salesDoc.data() as Map<String, dynamic>;
          int currentQuantity = data[_selectedProductId]['quantity'] ?? 0;
          data[_selectedProductId]['quantity'] = currentQuantity + _quantity;
          data['totalCost'] = (data['totalCost'] ?? 0) + totalCost;
          transaction.update(salesRef, data);
        } else {
          // If the document does not exist, create a new document
          Map<String, dynamic> data = {
            _selectedProductId: {'quantity': _quantity},
            'totalCost': totalCost,
          };
          transaction.set(salesRef, data);
        }
      });

      // Show Snackbar with success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sale recorded successfully.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error adding sale: $e');
      // Handle error
    }
  }

  Future<void> _fetchSalesByDate(DateTime selectedDate) async {
  try {
    String formattedDate =
        '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}';
    DocumentSnapshot salesDoc = await FirebaseFirestore.instance
        .collection('vendors')
        .doc(_vendorId)
        .collection('sales')
        .doc(formattedDate)
        .get();

    if (salesDoc.exists) {
      Map<String, dynamic> salesData = salesDoc.data() as Map<String, dynamic>;

      // Display total cost for the selected date
      double totalCost = salesData['totalCost'] ?? 0.0;
      print('Total Cost for $_selectedDate: $totalCost');

      // Display products sold with their quantities
      salesData.forEach((productId, productData) {
        if (productId != 'totalCost' && productId != 'date') {
          String productName = _products!
              .firstWhere((product) => product.id == productId)['name'];
          int quantity = productData as int; // Get the quantity directly
          print('$productName: $quantity');
        }
      });
    } else {
      print('No sales recorded for $_selectedDate');
    }
  } catch (e) {
    print('Error fetching sales: $e');
    // Handle error
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _products == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField(
                    value: _selectedProductId,
                    items: _products!
                        .map((product) => DropdownMenuItem(
                              value: product.id,
                              child: Text(product['name']),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProductId = value.toString();
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Select Product',
                    ),
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    initialValue: '1',
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _quantity = int.tryParse(value) ?? 1;
                      });
                    },
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      _addSale();
                    },
                    child: Text('Record Sale'),
                  ),
                  SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Select Date: '),
                      SizedBox(width: 8.0),
                      ElevatedButton(
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _selectedDate = pickedDate;
                            });
                            // Fetch sales data for selected date
                            _fetchSalesByDate(pickedDate);
                          }
                        },
                        child: Text('Pick Date'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
