import 'package:flutter/material.dart';
import 'package:intellicart/controllers/auth_controller.dart';
import 'package:intellicart/utils/show_snackBar.dart';
import 'package:intellicart/views/customer/auth/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthController _authController = AuthController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late String email;
 
  late String fullName;

  late String phoneNumber;

  late String password;

  _signUpUser() async {
    if (_formKey.currentState!.validate()) {
      await _authController.signUpUsers(email, fullName, phoneNumber, password);
      return showSnack(context, 'Congratulations, Account Created');
    } else {
      return showSnack(context, 'Please fields must not be empty');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Create Customer' 's Account',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                const CircleAvatar(
                  radius: 64,
                  backgroundColor: Colors.lightGreenAccent,
                ),
                Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Email must not be empty';
                      } else {
                        return null;
                      }
                    },
                    onChanged: (value) {
                      email = value;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Enter Email',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Full name must not be empty';
                      } else {
                        return null;
                      }
                    },
                    onChanged: (value) {
                      fullName = value;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Enter Full Name',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Phone Number must not be empty';
                      } else {
                        return null;
                      }
                    },
                    onChanged: (value) {
                      phoneNumber = value;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Enter Phone Number',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Password must not be empty';
                      } else {
                        return null;
                      }
                    },
                    onChanged: (value) {
                      password = value;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Password',
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _signUpUser();
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width - 40,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.lightGreenAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        'Register',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already Have An Account?'),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const LoginScreen();
                            },
                          ),
                        );
                      },
                      child: const Text('Login'),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
