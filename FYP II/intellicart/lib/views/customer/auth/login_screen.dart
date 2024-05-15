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
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  _loginUsers() async {
    setState(() {
      _isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      String res = await _authController.loginUsers(
        _emailController.text,
        _passwordController.text,
      );
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
        setState(() {
          _isLoading = false;
        });
        _emailController.clear(); // Clear the email field
        _passwordController.clear(); // Clear the password field
        if (context.mounted) {
          return showSnack(context, "Invalid ID or Password");
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
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Login Customer\'s Account',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 236, 236, 236),
                  fontSize: 15,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(13.0),
                child: TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please Email field must not be empty';
                    } else {
                      return null;
                    }
                  },
                  style: const TextStyle(
                    color: Color.fromARGB(255, 181, 184, 185),
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Enter Email Address',
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 181, 184, 185),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(13.0),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please Password field must not be empty';
                    } else {
                      return null;
                    }
                  },
                  style: const TextStyle(
                    color: Color.fromARGB(255, 181, 184, 185),
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Enter Password',
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 181, 184, 185),
                      fontSize: 14,
                    ),
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
                    color: const Color.fromARGB(255, 13, 26, 14),
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
                              color: Color.fromARGB(255, 181, 184, 185),
                              fontSize: 14,
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
                    style: TextStyle(
                      color: Color.fromARGB(255, 181, 184, 185),
                      fontSize: 14,
                    ),
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
                      style: TextStyle(
                        color: Color.fromARGB(255, 241, 242, 242),
                        fontSize: 14,
                      ),
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