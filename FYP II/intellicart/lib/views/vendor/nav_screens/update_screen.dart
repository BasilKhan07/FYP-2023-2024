import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intellicart/controllers/vendor_location_controller.dart';
import 'package:intellicart/controllers/vendor_product_controller.dart';
import 'package:intellicart/provider/selected_index_provider.dart';
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

  final TextEditingController _dropdownController = TextEditingController();

  final SelectedIndexController _selectedIndexController = Get.find();

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

    _selectedIndexController.setIndex(0);
  }

  Future<void> _addProduct() async {
    String productName = _dropdownController.text.toLowerCase();
    
    if (_productNames.contains(productName)) {
      showSnack(context, 'Product already exists');
      return;
    }

    String res = await _vendorProductController.addProduct(
      productName,
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
                        style: const TextStyle(
                            color: Color.fromARGB(255, 177, 181, 182),
                            fontSize: 12),
                      ),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Action',
                    labelStyle: TextStyle(
                        color: Color.fromARGB(255, 181, 184, 185),
                        fontSize: 14),
                    enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 13, 26, 14)),
                    ),
                  ),
                  style: const TextStyle(
                      color: Color.fromARGB(255, 181, 184, 185),
                      fontSize: 14), // Text color for dropdown items
                  dropdownColor: const Color.fromARGB(255, 13, 26, 14),
                ),
                const SizedBox(height: 10.0),
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
                          productName.toUpperCase(),
                          style: const TextStyle(
                              color: Color.fromARGB(255, 181, 184, 185),
                              fontSize: 12),
                        ),
                      );
                    }).toList(),
                    // Ensure items are unique by adding a key
                    key: UniqueKey(),
                    decoration: const InputDecoration(
                      labelText: 'Selling Product Name',
                      labelStyle: TextStyle(
                          color: Color.fromARGB(255, 181, 184, 185),
                          fontSize: 14),
                      enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromARGB(255, 13, 26, 14)),
                      ),
                    ),
                    style: const TextStyle(
                        color: Color.fromARGB(255, 181, 184, 185),
                        fontSize: 14), // Text color for dropdown items
                    dropdownColor: const Color.fromARGB(255, 13, 26, 14),
                  ),
                if (_selectedAction == "Add")
                  DropdownButtonFormField<String>(
                    value: _selectedProductName,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedProductName = value;
                        _dropdownController.text =
                            value ?? ''; // Update the text in the controller
                      });
                    },
                    items: [
                      'Orange',
                      'Banana',
                      'Apple',
                      'Tomato',
                      'Greenchilli'
                    ].map((String productName) {
                      return DropdownMenuItem<String>(
                        value: productName,
                        child: Text(
                          productName.toUpperCase(),
                          style: const TextStyle(
                              color: Color.fromARGB(255, 181, 184, 185),
                              fontSize: 12),
                        ),
                      );
                    }).toList(),
                    // Ensure items are unique by adding a key
                    key: UniqueKey(),
                    decoration: const InputDecoration(
                      labelText: 'Add New Product',
                      labelStyle: TextStyle(
                          color: Color.fromARGB(255, 181, 184, 185),
                          fontSize: 14),
                      enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromARGB(255, 13, 26, 14)),
                      ),
                    ),
                    style: const TextStyle(
                        color: Color.fromARGB(255, 181, 184, 185),
                        fontSize: 14), // Text color for dropdown items
                    dropdownColor: const Color.fromARGB(255, 13, 26, 14),
                    // Assign the controller to the dropdown
                  ),
                const SizedBox(height: 10.0),
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
                        style: const TextStyle(
                            color: Color.fromARGB(255, 181, 184, 185),
                            fontSize: 12),
                      ),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    labelStyle: TextStyle(
                        color: Color.fromARGB(255, 181, 184, 185),
                        fontSize: 14),
                    enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 13, 26, 14)),
                    ),
                  ),
                  style: const TextStyle(
                      color: Color.fromARGB(255, 181, 184, 185),
                      fontSize: 14), // Text color for dropdown items
                  dropdownColor: const Color.fromARGB(255, 13, 26, 14),
                ),
                TextField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price for 1 Kg (Rs) or 1 Dozen',
                    labelStyle: TextStyle(
                        color: Color.fromARGB(255, 181, 184, 185),
                        fontSize: 14),
                    enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 13, 26, 14)),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  enabled: !_disablePriceTextField,
                  style: const TextStyle(
                      color: Color.fromARGB(255, 181, 184, 185), fontSize: 14),
                ),
                const SizedBox(height: 30.0),
                InkWell(
                  onTap: () {
                    _performAction();
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width - 40,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 13, 26, 14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'Perform Action',
                              style: TextStyle(
                                color: Color.fromARGB(255, 181, 184, 185),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                SizedBox(
                  height: 300,
                  width: 300,
                  child: FutureBuilder<LatLng>(
                    future: _fetchVendorLocation(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
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
                              markerId: const MarkerId('destinationLocation'),
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
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    _updateVendorLocation();
                  },
                  child: const Text(
                    'Update Location',
                    style: TextStyle(
                        color: Color.fromARGB(255, 181, 184, 185),
                        fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: const Color.fromARGB(255, 13, 26, 14),
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
