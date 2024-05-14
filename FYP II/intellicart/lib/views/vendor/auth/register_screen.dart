import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intellicart/controllers/vendor_auth_controller.dart';
import 'package:intellicart/utils/show_snackbar.dart';

class VendorRegisterScreen extends StatefulWidget {
  const VendorRegisterScreen({Key? key});

  @override
  State<VendorRegisterScreen> createState() => _VendorRegisterScreenState();
}

class _VendorRegisterScreenState extends State<VendorRegisterScreen> {
  final VendorAuthController _authController = VendorAuthController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late String email;
  late String fullName;
  late String phoneNumber;
  late String password;
  bool _isLoading = false;
  Uint8List? _image;

  _signUpUser() async {
    setState(() {
      _isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      await _authController
          .signUpUsers(email, fullName, phoneNumber, password, _image)
          .whenComplete(() {
        setState(() {
          _formKey.currentState!.reset();
          _isLoading = false;
          _image = null;
        });
      });
      if (context.mounted) {
        return showSnack(context, 'Congratulations, Account Created');
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      return showSnack(context, 'Please fields must not be empty');
    }
  }

  selectGalleryImage() async {
    Uint8List im = await _authController.pickProfileImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
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
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Create Vendor\'s Account',
                      style: TextStyle(
                        color: Color.fromARGB(255, 216, 217, 218), fontSize: 15 // Change text color to white
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Stack(
                      children: [
                        _image != null
                            ? CircleAvatar(
                                radius: 55,
                                backgroundColor: Colors.lightGreenAccent,
                                backgroundImage: MemoryImage(_image!),
                              )
                            : const CircleAvatar(
                                radius: 55,
                                backgroundColor: Colors.lightGreenAccent,
                                backgroundImage: NetworkImage(
                                    'https://static.vecteezy.com/system/resources/thumbnails/009/292/244/small/default-avatar-icon-of-social-media-user-vector.jpg'),
                              ),
                        Positioned(
                          bottom: 35,
                          right: 35,
                          child: IconButton(
                            onPressed: () {
                              selectGalleryImage();
                            },
                            icon: const Icon(
                              CupertinoIcons.photo,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
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
                        style: TextStyle(color: Color.fromARGB(255, 181, 184, 185), fontSize: 14), // Change text color to white
                        decoration: const InputDecoration(
                          labelText: 'Enter Email',
                          labelStyle: TextStyle(color: Color.fromARGB(255, 181, 184, 185), fontSize: 14), // Change label text color to white
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
                        style: TextStyle(color: Color.fromARGB(255, 181, 184, 185), fontSize: 14), // Change text color to white
                        decoration: const InputDecoration(
                          labelText: 'Enter Full Name',
                          labelStyle: TextStyle(color: Color.fromARGB(255, 181, 184, 185), fontSize: 14), // Change label text color to white
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
                        style: TextStyle(color: Color.fromARGB(255, 181, 184, 185), fontSize: 14), // Change text color to white
                        decoration: const InputDecoration(
                          labelText: 'Enter Phone Number',
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
                            return 'Please Password must not be empty';
                          } else {
                            return null;
                          }
                        },
                        onChanged: (value) {
                          password = value;
                        },
                        style: TextStyle(color: Color.fromARGB(255, 181, 184, 185), fontSize: 14), // Change text color to white
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Color.fromARGB(255, 181, 184, 185), fontSize: 14), // Change label text color to white
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
                          color: Color.fromARGB(255, 13, 26, 14), // Change button color
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Register',
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
                          'Already Have An Account?',
                          style: TextStyle(color: Color.fromARGB(255, 181, 184, 185), fontSize: 14), // Change text color to white
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(color: Color.fromARGB(255, 232, 232, 232), fontSize: 14), // Change text color to white
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
