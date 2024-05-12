import 'package:flutter/material.dart';
import 'package:intellicart/views/customer/auth/login_screen.dart';
import 'package:intellicart/views/vendor/auth/login_screen.dart';

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
                child: Image.asset('assets/icons/final_logo.png'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CustomerLoginScreen(),
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
                      builder: (_) => const VendorLoginScreen(),
                    ),
                  );
                },
                child: const Text('Vendor'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
