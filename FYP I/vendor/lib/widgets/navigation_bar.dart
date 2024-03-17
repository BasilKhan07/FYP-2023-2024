import 'package:flutter/material.dart';
import 'package:vendor/screens/main_screen.dart';

class MainScreenBottomNavigationBar extends StatefulWidget {
  const MainScreenBottomNavigationBar({super.key});

  @override
  State<MainScreenBottomNavigationBar> createState() => _MainScreenBottomNavigationBarState();
}

class _MainScreenBottomNavigationBarState extends State<MainScreenBottomNavigationBar> {

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.lightGreenAccent,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.white,
      currentIndex: selectedIndex.value,
      iconSize: 20,
      onTap: (index) {
        setState(() {
          selectedIndex.value = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: "Dashboard",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: "Categories",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: "Products",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: "Sales",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: "Update",
        ),
      ],
    );
  }
}