import 'package:flutter/material.dart';
import 'package:vendor/screens/categories.dart';
import 'package:vendor/screens/dashboard.dart';
import 'package:vendor/screens/products.dart';
import 'package:vendor/screens/sales.dart';
import 'package:vendor/screens/update.dart';
import 'package:vendor/widgets/navigation_bar.dart';

final ValueNotifier selectedIndex = ValueNotifier(0);

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final List<Widget> _pages = [
    const DashboardScreen(),
    const CategoriesScreen(),
     ProductsScreen(),
     SalesScreen(),
     UpdateScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hi, Welcome Basil"),
        backgroundColor: Colors.lightGreenAccent,
        actions: [
          // IconButton(
          //   onPressed: () {},
          //   icon: const Icon(Icons.person),
          // )

          PopupMenuButton(
            child: const Padding(
              padding: EdgeInsets.all(10.0),
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/Basil.jpeg'),
                        
              ),
            ),
            onSelected: (value) {
              if (value == 'profile') {
                // print('Navigate to profile screen');
              } else if (value == 'logout') {
                // print('handle logout');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
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
