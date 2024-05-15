import 'package:flutter/material.dart';
import 'package:intellicart/controllers/vendor_auth_controller.dart';
import 'package:intellicart/provider/selected_index_provider.dart';
import 'package:intellicart/views/vendor/nav_screens/scan_screen.dart';
import 'package:intellicart/views/vendor/nav_screens/dashboard_screen.dart';
import 'package:intellicart/views/vendor/nav_screens/product_screen.dart';
import 'package:intellicart/views/vendor/nav_screens/sales_screen.dart';
import 'package:intellicart/views/vendor/nav_screens/update_screen.dart';
import 'package:get/get.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final VendorAuthController _authController = VendorAuthController();
  final SelectedIndexController _selectedIndexController = Get.put(SelectedIndexController());

  int _pageIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(),
    ScanScreen(),
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
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 13, 26, 14),
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
                  return Text(
                    'Welcome, ${snapshot.data}',
                    style: TextStyle(color: Color.fromARGB(255, 181, 184, 185), fontSize: 16), // Set text color to white
                  );
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
          currentIndex: _selectedIndexController.selectedIndex.value,
          onTap: (value) {
            setState(() {
              _selectedIndexController.setIndex(value);
              if (_pageIndex == 1) {
                _handleScanPageCalled();
              }
            });
          },
          unselectedItemColor: Color.fromARGB(255, 152, 155, 156), // Set unselected icon color to white
          selectedItemColor: const Color.fromARGB(255, 27, 66, 28),
          backgroundColor: Color.fromARGB(255, 13, 26, 14),// Set background color to white
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera),
              label: 'Scan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'My Products',
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
        body: Obx(() => _pages[_selectedIndexController.selectedIndex.value]),
      ),
    );
  }

  // Function to be called when the Scan page is called
  void _handleScanPageCalled() {
    // Call your function or perform your desired action here
    print('Scan page is called!');
  }
}
