import 'package:flutter/material.dart';
import 'package:vendor/models/sales_item.dart';
import 'package:vendor/widgets/sale_item_card.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  String selectedFilter = 'Previous 2 Days';

  @override
  Widget build(BuildContext context) {
    List<SaleItem> sales = [
      SaleItem(
        productName: 'Apple',
        category: 'Fruits',
        quantity: 2,
        totalPrice: 190,
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      SaleItem(
        productName: 'Tomato',
        category: 'Vegetables',
        quantity: 3,
        totalPrice: 130,
        date: DateTime.now().subtract(const Duration(days: 3)),
      ),
      SaleItem(
        productName: 'Banana',
        category: 'Fruits',
        quantity: 2,
        totalPrice: 230,
        date: DateTime.now().subtract(const Duration(days: 5)),
      ),
      SaleItem(
        productName: 'Tomato',
        category: 'Vegetables',
        quantity: 1,
        totalPrice: 130,
        date: DateTime.now().subtract(const Duration(days: 7)),
      ),
      SaleItem(
        productName: 'Orange',
        category: 'Fruits',
        quantity: 5,
        totalPrice: 175,
        date: DateTime.now().subtract(const Duration(days: 10)),
      ),
      SaleItem(
        productName: 'Chilli',
        category: 'Vegetables',
        quantity: 2,
        totalPrice: 65,
        date: DateTime.now().subtract(const Duration(days: 15)),
      ),
      SaleItem(
        productName: 'Apple',
        category: 'Fruits',
        quantity: 6,
        totalPrice: 190,
        date: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];
    List<SaleItem> filteredSales = sales
        .where((sale) {
          DateTime now = DateTime.now();
          if (selectedFilter == 'Previous 2 Days') {
            return now.difference(sale.date).inDays <= 2;
          } else if (selectedFilter == 'Past 2 Weeks') {
            return now.difference(sale.date).inDays <= 14;
          } else if (selectedFilter == 'Past Month') {
            return now.difference(sale.date).inDays <= 30;
          }
          return true;
        })
        .toList();

    return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedFilter,
              onChanged: (String? newValue) {
                setState(() {
                  selectedFilter = newValue!;
                });
              },
              items: [
                'Previous 2 Days',
                'Past 2 Weeks',
                'Past Month',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredSales.length,
              itemBuilder: (context, index) {
                return SaleItemCard(saleItem: filteredSales[index]);
              },
            ),
          ),
        ],
      );
  }
}
