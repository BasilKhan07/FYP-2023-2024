import 'package:flutter/material.dart';
import 'package:intellicart/controllers/customer_auth_controller.dart';
import 'package:intellicart/views/customer/nav_screens/favorites_screen.dart';
import 'package:intellicart/views/customer/nav_screens/feedback_screen.dart';
import 'package:intellicart/views/customer/nav_screens/nearbycart_screen.dart';
import 'package:intellicart/views/customer/nav_screens/quality_screen.dart';
import 'package:intellicart/views/customer/nav_screens/search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final CustomerAuthController _authController = CustomerAuthController();

  int _pageIndex = 0;

  final List<Widget> _pages = [
    NearbyScreen(),
    SearchScreen(),
    const FeedbackScreen(),
    const FavoritesScreen(),
    const ImagePredictionPage(),
  ];

  _signout() {
    _authController.signOut();
    Navigator.pop(context);
  }

  Future<String> _getCustomer() async {
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
            future: _getCustomer(),
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
              icon: const Icon(Icons.more_vert, color: Colors.white), // Set icon color to white
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
          unselectedItemColor: Color.fromARGB(255, 152, 155, 156), // Set unselected icon color to white
          selectedItemColor: const Color.fromARGB(255, 27, 66, 28),
          backgroundColor: Color.fromARGB(255, 13, 26, 14), // Set background color to dark green
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.near_me),
              label: 'Nearby',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.feedback),
              label: 'Feedback',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assessment),
              label: 'Quality',
            ),
          ],
        ),
        body: _pages[_pageIndex],
      ),
    );
  }
}
