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
  List<Map<String, dynamic>> _salesData = [];
  double? _totalCost;

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

        Map<String, dynamic> data = {
          counter: {
            'productName': productName,
            'quantity': _quantity,
            'totalCost': totalCost
          }
        };

        transaction.set(salesRef, data, SetOptions(merge: true));
      });

      // Show Snackbar with success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
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
      // Format the selected date to match the Firestore date format
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

      // Create a reference to the sales document for the selected date
      DocumentSnapshot salesDoc = await FirebaseFirestore.instance
          .collection('vendors')
          .doc(_vendorId)
          .collection('sales')
          .doc(formattedDate)
          .get();

      if (salesDoc.exists) {
        // Sales data exists for the selected date
        Map<String, dynamic>? salesData =
            salesDoc.data() as Map<String, dynamic>?;

        if (salesData != null) {
          double totalCost = 0;
          List<Map<String, dynamic>> salesList = [];

          // Iterate over each sale in the sales data
          salesData.forEach((key, value) {
            if (key != 'totalCost' && key != 'date') {
              // Add each sale's total cost to the totalCost variable
              totalCost += value['totalCost'].toDouble();

              // Create a map for each sale and add it to the salesList
              salesList.add({
                'productName': value['productName'],
                'quantity': value['quantity'],
              });
            }
          });

          // Update the state with the fetched sales data
          setState(() {
            _salesData = salesList;
            _totalCost = totalCost;
          });

          // Display the total cost for the selected date
          print('Total Cost for $formattedDate: $totalCost');
        } else {
          print('No sales data found for $formattedDate');
        }
      } else {
        // No sales recorded for the selected date
        print('No sales recorded for $formattedDate');
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
            ? const Center(child: CircularProgressIndicator())
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
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 181, 184, 185),
                                      fontSize: 14),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedProductId = value.toString();
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Select Product',
                        labelStyle: TextStyle(
                            color: Color.fromARGB(255, 181, 184, 185),
                            fontSize: 14),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 181, 184, 185)),
                        ),
                      ),
                      style: const TextStyle(
                          color: Color.fromARGB(255, 181, 184, 185),
                          fontSize: 14), // Text color for dropdown items
                      dropdownColor: const Color.fromARGB(
                          255, 13, 26, 14), // Background color of dropdown
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      initialValue: '1',
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                          color: Color.fromARGB(255, 181, 184, 185),
                          fontSize: 14),
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        labelStyle: TextStyle(
                            color: Color.fromARGB(255, 181, 184, 185),
                            fontSize: 14),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 181, 184, 185)),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _quantity = int.tryParse(value) ?? 1;
                        });
                      },
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () {
                        _addSale();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(
                            255, 13, 26, 14), // Change button color here
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              10), // Adjust the radius as needed
                        ),
                      ),
                      child: const Text('Record Sale',
                          style: TextStyle(
                              color: Color.fromARGB(255, 181, 184, 185),
                              fontSize: 14)),
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Select Date: ',
                            style: TextStyle(
                                color: Color.fromARGB(255, 181, 184, 185),
                                fontSize: 14)),
                        const SizedBox(width: 8.0),
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
                              borderRadius: BorderRadius.circular(
                                  10), // Adjust the radius as needed
                            ),
                            primary: const Color.fromARGB(
                                255, 13, 26, 14), // Change button color here
                          ),
                          child: const Text('Pick Date',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 181, 184, 185),
                                  fontSize: 14)),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    // Display sales data
                    Text(
                      'Sales Data for ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                      style: TextStyle(
                          color: Color.fromARGB(255, 181, 184, 185),
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.0),
                    if (_totalCost != null) ...{
                      Text(
                        'Total Cost: $_totalCost',
                        style: TextStyle(
                            color: Color.fromARGB(255, 181, 184, 185),
                            fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10.0),
                      for (var sale in _salesData) ...{
                        Text(
                          '${sale['productName']}: ${sale['quantity']}',
                          style: TextStyle(
                              color: Color.fromARGB(255, 181, 184, 185),
                              fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      },
                    } else ...{
                      Text(
                        'No sales data available for selected date',
                        style: TextStyle(
                            color: Color.fromARGB(255, 181, 184, 185),
                            fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    },
                  ],
                ),
              ),
      ),
    );
  }
}

