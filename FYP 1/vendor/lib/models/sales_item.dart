class SaleItem {
  final String productName;
  final String category;
  final int quantity;
  final double totalPrice;
  final DateTime date;

  SaleItem({
    required this.productName,
    required this.category,
    required this.quantity,
    required this.totalPrice,
    required this.date,
  });
}