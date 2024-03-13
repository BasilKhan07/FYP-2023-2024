import 'package:customer/screen/cart_details.dart';
import 'package:customer/screen/nearby_carts.dart';
import 'package:flutter/material.dart';

class FavoriteScreen extends StatelessWidget {

  final Set<String> favoritesSet = {'Cart 2'};

  FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> favoriteCarts = carts.where((cart) {
      return favoritesSet.contains(cart['name']);
    }).toList();

    return Scaffold(
      body: (favoriteCarts.isEmpty)
          ? const Center(child: Text('No favorite carts yet.'))
          : ListView.builder(
              itemCount: favoriteCarts.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(favoriteCarts[index]['sellerImage']),
                    ),
                    title: Text(favoriteCarts[index]['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Rating: ${favoriteCarts[index]['rating']}'),
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                          ],
                        ),
                        Text('Location: ${favoriteCarts[index]['location']}'),
                        Text('Seller: ${favoriteCarts[index]['sellerName']}'),
                        Text('Offering: ${favoriteCarts[index]['fruits'].join(', ')}'),
                      ],
                    ),
                    trailing: IconButton(onPressed: (){}, icon: const Icon(Icons.favorite, color: Colors.red,)),
                    onTap: () {
                      // Navigate to a new screen showing details of fruits and vegetables
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CartDetailsScreen(cart: favoriteCarts[index]),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}