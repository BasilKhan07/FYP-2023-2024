import 'package:customer/screen/cart_details.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

  // Dummy data for demonstration
  List<Map<String, dynamic>> carts = [
    {
      'id': 1,
      'name': 'Cart 1',
      'location': 'Johar Block 19, near Chase-up',
      'sellerName': 'Basil Khan',
      'sellerImage': 'assets/images/Basil.jpeg',
      'rating': 4.5,
      'fruits': ['Apple', 'Banana'],
      'vegetables': ['Tomato'],
      'prices': [190, 230, 130],
      'latitude': 37.7749,
      'longitude': -122.4194,
    },
    {
      'id': 2,
      'name': 'Cart 2',
      'location': 'Kamran Chowrangi, Block 12 Johar',
      'sellerName': 'Ahad Jameel',
      'sellerImage': 'assets/images/p1.jpeg',
      'rating': 3.8,
      'fruits': ['Orange', 'Apple'],
      'vegetables': '',
      'prices': [180, 200],
      'latitude': 37.7749,
      'longitude': -122.4194,
    },
    {
      'id': 3,
      'name': 'Cart 3',
      'location': 'Munawer Chowrangi, Sana Avenue Block 13',
      'sellerName': 'Baadshah Bhai',
      'sellerImage': 'assets/images/p2.jpg',
      'rating': 4.0,
      'fruits': ['Orange'],
      'vegetables': '',
      'prices': [170],
    },
    {
      'id': 4,
      'name': 'Cart 4',
      'location': 'Samama Block 20',
      'sellerName': 'Ali qadir',
      'sellerImage': 'assets/images/p3.jpg',
      'rating': 4.7,
      'fruits': '',
      'vegetables': ['Tomato', 'Chilli'],
      'prices': [140, 60],
    },
    {
      'id': 5,
      'name': 'Cart 5',
      'location': 'Pehlwan goth near Farhan Biryani',
      'sellerName': 'Bhalay Bhai',
      'sellerImage': 'assets/images/p4.jpg',
      'rating': 5,
      'fruits': '',
      'vegetables': ['Tomato'],
      'prices': [125],
    },
    {
      'id': 6,
      'name': 'Cart 6',
      'location': 'Johar Chworangi Basera tower',
      'sellerName': 'Jamshed Niazi',
      'sellerImage': 'assets/images/p5.jpg',
      'rating': 4.2,
      'fruits': ['Apple'],
      'vegetables': '',
      'prices': [195],
    },
    {
      'id': 7,
      'name': 'Cart 7',
      'location': 'RJ Mall Johar Pakwan',
      'sellerName': 'Bilal Fruits',
      'sellerImage': 'assets/images/p6.jpg',
      'rating': 3.9,
      'fruits': ['Banana', 'Orange'],
      'vegetables': [''],
      'prices': [230, 175],
    },
  ];

  void _searchCarts(String query) {
    setState(() {
      _searchResults = carts
          .where((cart) =>
              cart['fruits'].contains(query) ||
              cart['vegetables'].contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search for fruits or vegetables...',
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _searchCarts(_searchController.text),
            ),
          ),
        ),
      ),
      body: (_searchResults.isEmpty)
          ? const Center(child: Text('No results found.'))
          : ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          AssetImage(_searchResults[index]['sellerImage']),
                    ),
                    title: Text(_searchResults[index]['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Rating: ${_searchResults[index]['rating']}'),
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                          ],
                        ),
                        Text('Location: ${_searchResults[index]['location']}'),
                        Text('Seller: ${_searchResults[index]['sellerName']}'),
                        if (_searchResults[index]['fruits'] == '')
                          const Text('Fruits: None')
                        else
                          Text('Fruits: ${_searchResults[index]['fruits'].join(', ')}'),
                        if (_searchResults[index]['vegetables'] == '')
                          const Text('Vegetables: None')
                        else
                          Text(
                              'Vegetables: ${_searchResults[index]['vegetables'].join(', ')}'),
                      ],
                    ),
                    onTap: () {
                      // Navigate to a new screen showing details of fruits and vegetables
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CartDetailsScreen(cart: _searchResults[index]),
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
