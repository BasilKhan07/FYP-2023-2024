import 'package:flutter/material.dart';
import 'package:intellicart/controllers/customer_auth_controller.dart';
import 'package:intellicart/utils/show_snackBar.dart';
import 'package:intellicart/views/customer/auth/register_screen.dart';
import 'package:intellicart/views/customer/main_screen.dart';

class CustomerLoginScreen extends StatefulWidget {
  const CustomerLoginScreen({Key? key});

  @override
  State<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends State<CustomerLoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final CustomerAuthController _authController = CustomerAuthController();

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 6, 24, 8),
              Color.fromARGB(255, 109, 161, 121),
            ],
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Login Customer\'s Account',
                style: TextStyle(
                  
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 236, 236, 236), fontSize: 15// Change text color to white
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
                  style: TextStyle(color: Color.fromARGB(255, 181, 184, 185), fontSize: 14), // Change text color to white
                  decoration: const InputDecoration(
                    labelText: 'Enter Email Address',
                    labelStyle: TextStyle(color: Color.fromARGB(255, 181, 184, 185), fontSize: 14), // Change label text color to white
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
                  style: TextStyle(color: Color.fromARGB(255, 181, 184, 185), fontSize: 14), // Change text color to white
                  decoration: const InputDecoration(
                    labelText: 'Enter Password',
                    labelStyle: TextStyle(color: Color.fromARGB(255, 181, 184, 185), fontSize: 14), // Change label text color to white
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
                    color: Color.fromARGB(255, 13, 26, 14), // Change button color
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
                              color: Color.fromARGB(255, 181, 184, 185), fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                            ),
                          ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Need An Account?',
                    style: TextStyle(color: Color.fromARGB(255, 181, 184, 185), fontSize: 14), // Change text color to white
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CustomerRegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(color: Color.fromARGB(255, 241, 242, 242), fontSize: 14), // Change text color to white
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
