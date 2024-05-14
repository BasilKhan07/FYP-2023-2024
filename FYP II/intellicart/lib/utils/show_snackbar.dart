import 'package:flutter/material.dart';

showSnack(context, String title) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Color.fromARGB(255, 13, 26, 14),
      content: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
