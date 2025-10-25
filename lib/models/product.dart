class Product {
  final int? id;
  final String name;
  final int quantity;
  final double price;
  final String? imagePath;

  Product({
    this.id,
    required this.name,
    required this.quantity,
    required this.price,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price': price,
      'imagePath': imagePath,
    };
  }

  Product copyWith({int? id}) {
    return Product(
      id: id ?? this.id,
      name: this.name,
      quantity: this.quantity,
      price: this.price,
      imagePath: this.imagePath,
    );
  }

  // Convert a Map into a Product object.
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      quantity: map['quantity'],
      price: map['price'],
      imagePath: map['imagePath'],
    );
  }

  @override
  String toString() {
    return 'Product{id: $id, name: $name, quantity: $quantity, price: $price, imagePath: $imagePath}';
  }
}