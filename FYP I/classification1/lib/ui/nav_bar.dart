import 'package:classification1/main.dart';
import 'package:flutter/material.dart';

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
          label: "Nearby",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: "Search",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: "Feedback",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: "Favorites",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assessment),
          label: "Quality",
        ),
      ],
    );
  }
}