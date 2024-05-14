import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:intellicart/controllers/vendor_dashboard_controller.dart";

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final VendorDashboardController VDController = VendorDashboardController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;  //user.uid


  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
  }

  Stream<List<dynamic>> getData() async* {
    await for (List<dynamic> data in VDController.getNoOfCategories_getNoOfFruitsandVeg()) {
      yield data;
    }
  }

  //Not Used, as controller itself is sending its value in getData function
  Stream<List<dynamic>> getTotalSale() async* {
    await for (List<dynamic> data in VDController.getTodayTotalSale()) {
      yield data;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> headers = ['No of Categories', 'No of Fruits', 'No of Vegetables', 'Today\'s Sales (Rs)' , 'Total no. of Customers today'];
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 6, 24, 8), 
              Color.fromARGB(255, 109, 161, 121),
            ],
          ),
        ),
        child: StreamBuilder<List<dynamic>>(
          stream: getData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              //print(snapshot.error);
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              // Build a column with a ListTile for each value in the list
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final dynamic value = snapshot.data![index];
                  print('$index Value is : $value');
                  final String header = headers[index % headers.length]; // Get header using index
                        
                  // return Column(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     Padding(
                  //       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  //       child: Text(
                  //         header,
                  //         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  //       ),
                  //     ),
                  //     ListTile(
                  //       title: Text(value.toString()),
                  //     ),
                  //   ],
                  // );
                  return SingleChildScrollView(
                    child: Card(
                      color:const Color.fromARGB(255, 200, 234, 199),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Center(
                          child: Text(
                            header,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 14, 15, 16), 
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Center(
                              child: Text(value.toString(),
                                style: const TextStyle(fontSize: 16),
                                ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );  
            } // else ends
          },
        ),
      ),
    );
  }
}
