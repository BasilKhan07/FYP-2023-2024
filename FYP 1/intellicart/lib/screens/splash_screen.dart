import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intellicart/screens/user_type_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return FlutterSplashScreen(
      duration: const Duration(milliseconds: 5000),
      nextScreen: const UserTypeSelectionScreen(),
      backgroundColor: const Color.fromARGB(249,252,254,255),
      splashScreenBody: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 100,
            ),
            Image.asset(
              'assets/logo2.png',
              height: 300,
              width: 300,

            ),
            const Spacer(),
            Text(
              "IntelliCART",
              style: GoogleFonts.merriweather(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: Colors.lightGreen
              ),
            ),
            const SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }
}
