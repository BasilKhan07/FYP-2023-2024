import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intellicart/controllers/vendor_location_controller.dart';
import 'package:intellicart/controllers/vendor_product_controller.dart';
import 'package:intellicart/utils/show_snackbar.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({Key? key}) : super(key: key);

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  final VendorProductController _vendorProductController =
      VendorProductController();

  final VendorLocationController _vendorLocationController =
      VendorLocationController();

  final TextEditingController _priceController = TextEditingController();

  final TextEditingController _nameController = TextEditingController();

  String? _selectedCategory;

  String? _selectedProductName;

  bool _isLoading = false;

  String? _selectedAction;

  bool _disablePriceTextField = false;

  late LatLng _vendorLocation = const LatLng(0, 0);

  List<String> _productNames = [];

  _performAction() async {
    setState(() {
      _isLoading = true;
    });

    if (_selectedAction == 'Add') {
      await _addProduct();
    } else if (_selectedAction == 'Update') {
      await _updateProduct();
    } else if (_selectedAction == 'Delete') {
      await _deleteProduct();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _addProduct() async {
    String res = await _vendorProductController.addProduct(
      _nameController.text,
      _selectedCategory!,
      _priceController.text,
    );
    try {
      if (res == 'success') {
        if (context.mounted) {
          showSnack(context, 'Product Added Successfully');
        }
      } else {
        if (context.mounted) {
          showSnack(context, res);
        }
      }
    } catch (e) {
      if (context.mounted) {
          showSnack(context, e.toString());
      }
    }
  }

  Future<void> _updateProduct() async {
    String res = await _vendorProductController.updateProduct(
      _selectedProductName!,
      _selectedCategory!,
      _priceController.text,
    );
    try {
      if (res == 'success') {
        if (context.mounted) {
          showSnack(context, 'Product Updated Successfully');
        }
      } else {
        if (context.mounted) {
          showSnack(context, res);
        }
      }
    } catch (e) {
      if (context.mounted) {
        showSnack(context, e.toString());
      }
    }
  }

  Future<void> _deleteProduct() async {
    String res = await _vendorProductController.deleteProduct(
      _selectedProductName!,
      _selectedCategory!,
    );
    try {
      if (res == 'success') {
        if (context.mounted) {
          showSnack(context, 'Product Deleted Successfully');
        }
      } else {
        if (context.mounted) {
          showSnack(context, res);
        }
      }
    } catch (e) {
      if (context.mounted) {
        showSnack(context, e.toString());
      }
    }
  }

  Future<LatLng> _fetchVendorLocation() async {
    LatLng location = await _vendorLocationController.getVendorLocation();
    return location;
  }

  Future<void> _updateVendorLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {}

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String res = await _vendorLocationController.updateVendorLocation(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _vendorLocation = LatLng(position.latitude, position.longitude);
      });

      if (res == 'success') {
        if (context.mounted) {
          showSnack(context, 'Location updated successfully');
        }
      }
    } catch (e) {
      if (context.mounted) {
        showSnack(context, e.toString());
      }
    }
  }

  Future<void> _fetchProductNames() async {
    try {
      List<String> productNames =
          await _vendorProductController.getProductNames();
      setState(() {
        _productNames = productNames;
      });
    } catch (e) {
      if (context.mounted) {
        showSnack(context, e.toString());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProductNames();
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedAction,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedAction = value;
                      _disablePriceTextField = value == 'Delete';
                    });
                  },
                  items: ['Add', 'Update', 'Delete'].map((String action) {
                    return DropdownMenuItem<String>(
                      value: action,
                      child: Text(
                        action,
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Action',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 13, 26, 14)),
                    ),
                  ),
                  style: TextStyle(color: Colors.white), // Text color for dropdown items
  dropdownColor: Color.fromARGB(255, 13, 26, 14), 
                ),
                SizedBox(height: 10.0),
                if (_selectedAction != "Add")
                  DropdownButtonFormField<String>(
                    value: _selectedProductName,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedProductName = value;
                      });
                    },
                    items: _productNames.map((String productName) {
                      return DropdownMenuItem<String>(
                        value: productName,
                        child: Text(
                          productName,
                          style: TextStyle(color: Colors.white),
                        ),
                        
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Selling Product Name',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 13, 26, 14)),
                      ),
                    ),
                    style: TextStyle(color: Colors.white), // Text color for dropdown items
  dropdownColor: Color.fromARGB(255, 13, 26, 14), 
                  ),
                if(_selectedAction == "Add")
                  TextField(
                    controller: _nameController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'New Product Name',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 13, 26, 14)),
                      ),
                    ),
                  ),
                SizedBox(height: 20.0),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  items: ['Fruit', 'Vegetable'].map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(
                        category,
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 13, 26, 14)),
                    ),
                    
                  ),
                  style: TextStyle(color: Colors.white), // Text color for dropdown items
  dropdownColor: Color.fromARGB(255, 13, 26, 14), 
                ),
                TextField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Price for 1 Kg (Rs) or 1 Dozen',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 13, 26, 14)),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  enabled: !_disablePriceTextField,
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 20.0),
                InkWell(
                  onTap: () {
                    _performAction();
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width - 40,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 13, 26, 14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: _isLoading
                          ? CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Text(
                              'Perform Action',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 5,
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                SizedBox(
                  height: 300,
                  width: 300,
                  child: FutureBuilder<LatLng>(
                    future: _fetchVendorLocation(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        _vendorLocation = snapshot.data!;
                        return GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _vendorLocation,
                            zoom: 12,
                          ),
                          markers: {
                            Marker(
                              markerId: MarkerId('destinationLocation'),
                              icon: BitmapDescriptor.defaultMarker,
                              position: _vendorLocation,
                              draggable: true,
                            ),
                          },
                        );
                      }
                    },
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    _updateVendorLocation();
                  },
                  child: Text(
                    'Update Location',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 13, 26, 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
