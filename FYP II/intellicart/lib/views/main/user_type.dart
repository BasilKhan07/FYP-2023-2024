import 'package:flutter/material.dart';
import 'package:intellicart/views/customer/auth/register_screen.dart';
import 'package:intellicart/views/vendor/auth/register_screen.dart';

class UserTypeSelectionScreen extends StatelessWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Select User Type'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: const EdgeInsets.only(
                top: 30,
                bottom: 30,
                left: 20,
                right: 20,
              ),
              width: 300,
              child: Image.asset('assets/icons/logo2.PNG'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CustomerRegisterScreen(),
                  ),
                );
              },
              child: const Text('Customer'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VendorRegisterScreen(),
                  ),
                );
              },
              child: const Text('Vendor'),
            ),
          ],
        ),
      ),
    );
  }
}
