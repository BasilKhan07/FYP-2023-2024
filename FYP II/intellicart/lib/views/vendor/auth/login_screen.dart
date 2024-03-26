import 'package:flutter/material.dart';
import 'package:intellicart/controllers/vendor_auth_controller.dart';
import 'package:intellicart/utils/show_snackBar.dart';
import 'package:intellicart/views/vendor/main_screen.dart';

class VendorLoginScreen extends StatefulWidget {
  const VendorLoginScreen({super.key});

  @override
  State<VendorLoginScreen> createState() => _VendorLoginScreenState();
}

class _VendorLoginScreenState extends State<VendorLoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final VendorAuthController _authController = VendorAuthController();

  late String email;

  late String password;

  bool _isLoading = false;

  _loginUsers() async {
    setState(() {
      _isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      String res = await _authController.loginUsers(email, password);
      if (res == 'success' && context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) {
              return const MainScreen();
            },
          ),
        );
      } else {
        if (context.mounted) {
          return showSnack(context, res);
        }
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      return showSnack(context, 'Please fields must not be empty');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Login Customer' 's Account',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(13.0),
              child: TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please Email field must not be empty';
                  } else {
                    return null;
                  }
                },
                onChanged: (value) {
                  email = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Enter Email Address',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(13.0),
              child: TextFormField(
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please Password field must not be empty';
                  } else {
                    return null;
                  }
                },
                onChanged: (value) {
                  password = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Enter Password',
                ),
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () {
                _loginUsers();
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
                          'Login',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Need An Account?'),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Register'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}