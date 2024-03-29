import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intellicart/controllers/vendor_auth_controller.dart';
import 'package:intellicart/views/vendor/nav_screens/categories_screen.dart';
import 'package:intellicart/views/vendor/nav_screens/dashboard_screen.dart';
import 'package:intellicart/views/vendor/nav_screens/product_screen.dart';
import 'package:intellicart/views/vendor/nav_screens/sales_screen.dart';
import 'package:intellicart/views/vendor/nav_screens/update_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final VendorAuthController _authController = VendorAuthController();

  int _pageIndex = 0;

  final List<Widget> _pages = const [
    DashboardScreen(),
    CategoriesScreen(),
    ProductsScreen(),
    SalesScreen(),
    UpdateScreen(),
  ];

  _signout() {
    _authController.signOut();
    Navigator.pop(context);
  }

  Future<String> getUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('vendors')
          .doc(user.uid)
          .get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      if (userDoc.exists) {
        String fullName = userData['fullName'];
        int indexOfSpace = fullName.indexOf(' ');
        String username =
            indexOfSpace != -1 ? fullName.substring(0, indexOfSpace) : fullName;
        return username;
      } else {
        return 'Username not found';
      }
    } else {
      return 'User not logged in';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: getUserInfo(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            } else {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Text('Welcome, ${snapshot.data}');
              }
            }
          },
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'signout',
                child: Text('Sign Out'),
              ),
            ],
            onSelected: (value) {
              if (value == 'signout') {
                _signout();
              }
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _pageIndex,
        onTap: (value) {
          setState(() {
            _pageIndex = value;
          });
        },
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.green,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Sales',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Update',
          ),
        ],
      ),
      body: _pages[_pageIndex],
    );
  }
}
