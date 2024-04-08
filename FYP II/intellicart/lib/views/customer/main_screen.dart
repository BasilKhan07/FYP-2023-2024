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
    const NearbyScreen(),
    SearchScreen(),
    const FeedbackScreen(),
    const FavoritesScreen(),
    const QualityAssessmentScreen(),
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
    return Scaffold(
      appBar: AppBar(
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
    );
  }
}
