
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vendor/models/sales_item.dart';

class SaleItemCard extends StatelessWidget {
  final SaleItem saleItem;

  const SaleItemCard({super.key, required this.saleItem});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text('${saleItem.productName} - ${saleItem.category}'),
        subtitle: Text(
          'Quantity: ${saleItem.quantity} | Total Price: Rs. ${saleItem.totalPrice * saleItem.quantity}',
        ),
        trailing: Text(
          'Date: ${DateFormat.yMd().format(saleItem.date)}',
        ),
      ),
    );
  }
}
