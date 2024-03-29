import 'package:flutter/material.dart';
import 'package:intellicart/controllers/vendor_product_controller.dart';
import 'package:intellicart/utils/show_snackbar.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  final VendorProductController _vendorProductController =
      VendorProductController();

  final TextEditingController _priceController = TextEditingController();

  final TextEditingController _nameController = TextEditingController();

  String? _selectedCategory;

  bool _isLoading = false;

  String? _selectedAction;

  bool _disablePriceTextField = false;

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
      _nameController.text,
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
      _nameController.text,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
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
                    // Disable price TextField when "Delete" is selected
                    _disablePriceTextField = value == 'Delete';
                  });
                },
                items: ['Add', 'Update', 'Delete'].map((String action) {
                  return DropdownMenuItem<String>(
                    value: action,
                    child: Text(action),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Action',
                ),
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
              ),
              const SizedBox(height: 20.0),
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
                    child: Text(category),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Category',
                ),
              ),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price for 1 Kg (Rs) or 1 Dozen',
                ),
                keyboardType: TextInputType.number,
                enabled: !_disablePriceTextField, // Control enabled state
              ),
              const SizedBox(height: 20.0),
              InkWell(
                onTap: () {
                  _performAction();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width - 40,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.lightGreenAccent,
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
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 5,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
