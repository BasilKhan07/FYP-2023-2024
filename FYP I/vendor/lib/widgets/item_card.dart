import 'package:flutter/material.dart';
import 'package:vendor/models/items.dart';

class ItemCard extends StatelessWidget {
  final Item item;

  const ItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(item.name),
      subtitle: Text('Price: ${item.price}'),
      leading: CircleAvatar(
        backgroundImage: AssetImage('assets/images/${item.name.toLowerCase()}.jpg'),
      ),
    );
  }
}