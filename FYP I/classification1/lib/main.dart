import 'dart:io';
import 'package:camera/camera.dart';
import 'package:classification1/ui/camera.dart';
import 'package:classification1/ui/gallery.dart';
import 'package:classification1/ui/nav_bar.dart';
import 'package:flutter/material.dart';
final ValueNotifier selectedIndex = ValueNotifier(0);
Future<void> main() async {
  runApp(const BottomNavigationBarApp());
}

class BottomNavigationBarApp extends StatelessWidget {
  const BottomNavigationBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BottomNavigationBarExample(),
    );
  }
}

class BottomNavigationBarExample extends StatefulWidget {
  const BottomNavigationBarExample({super.key});

  @override
  State<BottomNavigationBarExample> createState() =>
      _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState
    extends State<BottomNavigationBarExample> {
  late CameraDescription cameraDescription;
  int _selectedIndex = 0;
  List<Widget>? _widgetOptions;

  bool cameraIsAvailable = Platform.isAndroid || Platform.isIOS;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initPages();
    });
  }

  initPages() async {
    _widgetOptions = [const GalleryScreen(),];

    if (cameraIsAvailable) {
      // get list available camera
      cameraDescription = (await availableCameras()).first;
      _widgetOptions!.add(CameraScreen(camera: cameraDescription));
    }

    setState(() {});
  }

  void _onItemTapped(int index) {
    if (!cameraIsAvailable) {
      debugPrint("This is not supported on your current platform");
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Image.asset('assets/images/tfl_logo.png'),
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
              //   Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const ProfileScreen(),
              //   ),
              // );
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
      body: Center(
        child: _widgetOptions?.elementAt(_selectedIndex),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.image),
      //       label: 'Gallery screen',
      //     ),
      //     // BottomNavigationBarItem(
      //     //   icon: Icon(Icons.camera),
      //     //   label: 'Live Camera',
      //     // ),
      //   ],
      //   currentIndex: _selectedIndex,
      //   selectedItemColor: Colors.amber[800],
      //   onTap: _onItemTapped,
      // ),
      bottomNavigationBar: const MainScreenBottomNavigationBar()
    );      
  }
}