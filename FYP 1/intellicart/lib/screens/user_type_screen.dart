import 'package:flutter/material.dart';
import 'package:intellicart/screens/loginsignup_screen.dart';

class UserTypeSelectionScreen extends StatelessWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Type Selection'),
        backgroundColor: Colors.lightGreenAccent,
      ),
      backgroundColor: const Color.fromARGB(255, 199, 238, 155),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginSignupScreen(
                      userType: 'customer',
                    ),
                  ),
                );
              },
              child: const Text('I am a Customer'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const LoginSignupScreen(userType: 'vendor'),
                  ),
                );
              },
              child: const Text('I am a Vendor'),
            ),
          ],
        ),
      ),
    );
  }
}
