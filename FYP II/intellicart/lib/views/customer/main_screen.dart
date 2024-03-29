import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  final List<Widget> _pages = const [
    NearbyScreen(),
    SearchScreen(),
    FeedbackScreen(),
    FavoritesScreen(),
    ImagePredictionPage(),
  ];

  _signout() {
    _authController.signOut();
    Navigator.pop(context);
  }

  Future<String> getUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('customers')
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
