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

  final List<Widget> _pages = [
    const DashboardScreen(),
    const CategoriesScreen(),
    ProductsScreen(),
    const SalesScreen(),
    const UpdateScreen(),
  ];

  _signout() {
    _authController.signOut();
    Navigator.pop(context);
  }

 Future<String> _getVendor() async {
  return await _authController.getUserInfo();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: FutureBuilder<String>(
          future: _getVendor(),
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
