class MenuCategory {
  final String id, name;
  final String? image;
  MenuCategory({required this.id, required this.name, this.image});
  factory MenuCategory.fromMap(String id, Map<String,dynamic> m) =>
    MenuCategory(id: id, name: m['name'] ?? '', image: m['image']);
}

class MenuItem {
  final String id, name, categoryId;
  final double price;
  final double? salePrice;
  final String? image, description;
  final bool available;
  MenuItem({required this.id, required this.name, required this.categoryId,
    required this.price, this.salePrice, this.image, this.description, this.available = true});
  factory MenuItem.fromMap(String id, Map<String,dynamic> m) => MenuItem(
    id: id, name: m['name'] ?? '', categoryId: m['categoryId'] ?? '',
    price: (m['price'] ?? 0).toDouble(),
    salePrice: m['salePrice'] != null ? (m['salePrice'] as num).toDouble() : null,
    image: m['image'], description: m['description'],
    available: m['available'] != false,
  );
}

class Offer {
  final String id, title;
  final String? description, image, expiresAt;
  final int discount;
  Offer({required this.id, required this.title, this.description,
    this.image, this.expiresAt, this.discount = 0});
  factory Offer.fromMap(String id, Map<String,dynamic> m) => Offer(
    id: id, title: m['title'] ?? '', description: m['description'],
    image: m['image'], expiresAt: m['expiresAt'],
    discount: (m['discount'] ?? 0).toInt(),
  );
}

class CartItem {
  final MenuItem item;
  int qty;
  CartItem({required this.item, this.qty = 1});
  double get total => (item.salePrice ?? item.price) * qty;
}

class AppOrder {
  final String id, status;
  final double total;
  final List<dynamic> items;
  final String? customerName, address, phone, paymentMethod;
  final DateTime? createdAt;
  AppOrder({required this.id, required this.status, required this.total,
    required this.items, this.customerName, this.address, this.phone,
    this.paymentMethod, this.createdAt});
  factory AppOrder.fromMap(String id, Map<String,dynamic> m) => AppOrder(
    id: id, status: m['status'] ?? 'pending',
    total: (m['total'] ?? 0).toDouble(),
    items: m['items'] ?? [],
    customerName: m['customerName'],
    address: m['address'],
    phone: m['phone'],
    paymentMethod: m['paymentMethod'],
    createdAt: m['createdAt']?.toDate(),
  );
}

class Review {
  final String id, name;
  final int stars;
  final String? comment;
  Review({required this.id, required this.name, required this.stars, this.comment});
  factory Review.fromMap(String id, Map<String,dynamic> m) => Review(
    id: id, name: m['name'] ?? '', stars: (m['stars'] ?? 5).toInt(), comment: m['comment']);
}
