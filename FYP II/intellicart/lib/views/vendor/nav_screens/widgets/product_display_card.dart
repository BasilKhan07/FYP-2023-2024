import 'package:flutter/material.dart';


class CustomCategoryCard extends StatelessWidget {
  final List<dynamic>? displayList;
  final String categoryName;
  final String image;

  const CustomCategoryCard({
    super.key,
    required this.displayList,
    required this.categoryName,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color.fromARGB(255, 135, 218, 63).withOpacity(1),
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              categoryName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Center(
            child: Image.asset(
              image,
              height: 150.0,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
          ),
          displayList != null && displayList!.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: displayList!.length,
                  itemBuilder: (context, index) {
                    String productPrice = displayList![index]['price'].toStringAsFixed(2);
                    String productName = displayList![index]['name'];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 173, 217, 107).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: ListTile(
                        title: Text(
                          productName.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                          ),
                        ),
                        subtitle: Text('Price: Rs. $productPrice per kg / dozen', style: TextStyle(fontSize: 13),),
                      ),
                    );
                  },
                )
              : const ListTile(
                  title: Text('No Vegetables listed for Sale',
                  style: TextStyle(fontSize: 15) ,),
                ),
        ],
      ),
    );
  }
}
