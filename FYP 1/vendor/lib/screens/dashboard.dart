import 'package:flutter/material.dart';
import 'package:vendor/widgets/dashboard_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DashboardCard(title: "Number of Categories", value:  "2"),
              DashboardCard(title: "Number of Fruits", value:  "3"),
              DashboardCard(title: "Number of Vegetables", value:  "2"),
              DashboardCard(title: "Today's Sales", value:  "Rs. 5000"),
              DashboardCard(title: "Average Number of Customers", value:  "100 per day"),
            ],
          ),
        ),
      ),
    );
  }
}
