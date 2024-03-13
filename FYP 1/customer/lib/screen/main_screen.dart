import 'package:customer/screen/favorites.dart';
import 'package:customer/screen/feedback.dart';
import 'package:customer/screen/nearby_carts.dart';
import 'package:customer/screen/profile.dart';
import 'package:customer/screen/search.dart';
import 'package:customer/widgets/navigation_bar.dart';
import 'package:flutter/material.dart';

final ValueNotifier selectedIndex = ValueNotifier(0);

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final List<Widget> _pages = [
    const NearbyCartsScreen(),
    const SearchScreen(),
    FeedbackScreen(),
    FavoriteScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hi, Welcome Ali",
              style: TextStyle(fontSize: 20),
            ),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.white, size: 15),
                Text(
                  "Gulistan-e-Johar, Block 19",
                  style: TextStyle(fontSize: 15),
                ),
              ],
            )
          ],
        ),
        backgroundColor: Colors.lightGreenAccent,
        actions: [
          PopupMenuButton(
            child: const Padding(
              padding: EdgeInsets.all(10.0),
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/Ali.jpg'),
              ),
            ),
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
              } else if (value == 'logout') {
                // print('handle logout');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                ),
              ),
              const PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text('Logout'),
                ),
              )
            ],
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: selectedIndex,
        builder: (context, snapshot, child) {
          return _pages[selectedIndex.value];
        },
      ),
      bottomNavigationBar: const MainScreenBottomNavigationBar(),
    );
  }
}
