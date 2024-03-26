import 'package:flutter/material.dart';
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
  int _pageIndex = 0;

  final List<Widget> _pages = const [
    DashboardScreen(),
    CategoriesScreen(),
    ProductsScreen(),
    SalesScreen(),
    UpdateScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome User'),
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
