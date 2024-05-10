import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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
  late String counter;
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
      String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Create a reference to the sales document for the current date
      DocumentReference salesRef = FirebaseFirestore.instance
          .collection('vendors')
          .doc(_vendorId)
          .collection('sales')
          .doc(formattedDate);

      // Use a transaction to update the sales document atomically
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Calculate the total cost for the new sale
        double productPrice = _products!
            .firstWhere((product) => product.id == _selectedProductId)['price'];
        double totalCost = _calculateTotalCost(productPrice);

        String productName = _products!
        .firstWhere((product) => product.id == _selectedProductId)['name'];

        DocumentSnapshot salesDoc = await transaction.get(salesRef);

        if (salesDoc.exists) {
          Map<String, dynamic> data = salesDoc.data() as Map<String, dynamic>;

          if (data.isNotEmpty) {
            List<String> keys = data.keys.toList();
            String lastSaleCounter = keys.last;

            setState(() {
              int temp = int.parse(lastSaleCounter) + 1;
              counter = temp.toString();
            });
          }
        } else {
          setState(() {
            counter = '1';
          });
        }

        Map<String, dynamic> data = { counter : {
          'productName' : productName,
          'quantity' : _quantity,
          'totalCost' : totalCost }
        };

        transaction.set(salesRef, data, SetOptions(merge: true));
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
      String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      DocumentSnapshot salesDoc = await FirebaseFirestore.instance
          .collection('vendors')
          .doc(_vendorId)
          .collection('sales')
          .doc(formattedDate)
          .get();

      if (salesDoc.exists) {
        Map<String, dynamic> salesData = salesDoc.data() as Map<String, dynamic>;

        double totalCost = salesData['totalCost'] ?? 0.0;
        print('Total Cost for $_selectedDate: $totalCost');

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
        child: _products == null
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
            child: Text(
              product['name'],
              style: TextStyle(color: Colors.white),
            ),
          ))
      .toList(),
  onChanged: (value) {
    setState(() {
      _selectedProductId = value.toString();
    });
  },
  decoration: InputDecoration(
    labelText: 'Select Product',
    labelStyle: TextStyle(color: Colors.white),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.white),
    ),
  ),
  style: TextStyle(color: Colors.white), // Text color for dropdown items
  dropdownColor: Color.fromARGB(255, 13, 26, 14), // Background color of dropdown
),

                  SizedBox(height: 20.0),
                  TextFormField(
                    initialValue: '1',
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
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
  style: ElevatedButton.styleFrom(
    primary: Color.fromARGB(255, 13, 26, 14), // Change button color here
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10), // Adjust the radius as needed
    ),
  ),
  child: Text('Record Sale', style: TextStyle(color: Colors.white)),
),

                  SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Select Date: ', style: TextStyle(color: Colors.white)),
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
                        
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Adjust the radius as needed
                           ),
                          primary: Color.fromARGB(255, 13, 26, 14), // Change button color here
                        ),
                        child: Text('Pick Date', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
