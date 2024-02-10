class Order {
  final String addressID;
  final bool isSuccess;
  final String orderBy;
  final String orderId;
  final String orderTime;
  final String paymentDetails;
  final List<Product> products;
  final String riderUID;
  final String sellerUID;
  final String status;
  final double totalAmount;

  Order({
    required this.addressID,
    required this.isSuccess,
    required this.orderBy,
    required this.orderId,
    required this.orderTime,
    required this.paymentDetails,
    required this.products,
    required this.riderUID,
    required this.sellerUID,
    required this.status,
    required this.totalAmount,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // Extract the products array from json
    List<dynamic> productsJson = json['products'];
    List<Product> products = productsJson.map((productJson) => Product.fromJson(productJson)).toList();

    return Order(
      addressID: json['addressID'],
      isSuccess: json['isSuccess'],
      orderBy: json['orderBy'],
      orderId: json['orderId'],
      orderTime: json['orderTime'],
      paymentDetails: json['paymentDetails'],
      products: products,
      riderUID: json['riderUID'],
      sellerUID: json['sellerUID'],
      status: json['status'],
      totalAmount: json['totalAmount'],
    );
  }
}

class Product {
  final String cartID;
  final String foodItemId;
  final int itemCounter;
  final double productPrice;
  final String productTitle;
  final String thumbnailUrl;

  Product({
    required this.cartID,
    required this.foodItemId,
    required this.itemCounter,
    required this.productPrice,
    required this.productTitle,
    required this.thumbnailUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      cartID: json['cartID'],
      foodItemId: json['foodItemId'],
      itemCounter: json['itemCounter'],
      productPrice: double.parse(json['productPrice']),
      productTitle: json['productTitle'],
      thumbnailUrl: json['thumbnailUrl'],
    );
  }
}
