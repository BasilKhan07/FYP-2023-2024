import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key});

  @override
  _UpdateScreenState createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  String selectedCategory = 'Fruits';
  String selectedOperation = 'Add';
  String selectedExistingItem = '';
  String newName = '';
  double newPrice = 0.0;
  String newImage = '';
  bool nameDisabled = false;

  List<String> categories = ['Fruits', 'Vegetables'];
  List<String> existingFruits = [
    'Apple',
    'Banana',
    'Orange'
  ]; // Replace with your actual existing fruits
  List<String> existingVegetables = [
    'Tomato',
    'Chilli'
  ]; // Replace with your actual existing vegetables

  Future<void> _getImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        newImage = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButton<String>(
              value: selectedCategory,
              
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue!;
                  selectedExistingItem =
                      ''; // Reset selected item when category changes
                });
              },
              items: categories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16.0),
            DropdownButton<String>(
              value: selectedOperation,
              onChanged: (String? newValue) {
                setState(() {
                  selectedOperation = newValue!;
                  selectedExistingItem =
                      ''; // Reset selected item when operation changes
                  nameDisabled = selectedOperation == 'Update';
                });
              },
              items: ['Add', 'Update']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16.0),
            if (selectedCategory == 'Fruits' && selectedOperation == 'Update')
              DropdownButton<String>(
                value: existingFruits.first,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedExistingItem = newValue!;
                  });
                },
                items: existingFruits
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            if (selectedCategory == 'Vegetables' &&
                selectedOperation == 'Update')
              DropdownButton<String>(
                value: existingVegetables.first,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedExistingItem = newValue!;
                  });
                },
                items: existingVegetables
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16.0),
            TextField(
              decoration: const InputDecoration(labelText: 'Name'),
              onChanged: (value) {
                setState(() {
                  newName = value;
                });
              },
              enabled: !nameDisabled,
            ),
            const SizedBox(height: 16.0),
            TextField(
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                setState(() {
                  newPrice = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _getImage,
                  child: const Text('Select Image'),
                ),
                const SizedBox(width: 8.0),
                Text(newImage),
              ],
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                // Perform update logic with the entered data
                // For simplicity, you can print the entered data for now
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return const Text('Update Successfully');
                        },
                      ),
                    );
                  },
                );
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
