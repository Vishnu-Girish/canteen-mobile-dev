class AppData {
  static List<Map<String, dynamic>> cart = [];
  static double walletBalance = 300;
  static int nextOrderId = 242;
  static List<Map<String, dynamic>> orders = [
    {'id': 241, 'status': 'Preparing', 'items': 'Idli sambar x1, veg puffs x1', 'total': 50},
    {'id': 238, 'status': 'Picked up', 'items': 'Idli sambar x1', 'total': 30},
  ];

  static double cartTotal() {
    double total = 0;
    for (var item in cart) {
      total += item['price'] * item['qty'];
    }
    return total;
  }

  static void addToCart(String name, dynamic price) {
    for (var item in cart) {
      if (item['name'] == name) {
        item['qty'] += 1;
        return;
      }
    }
    cart.add({'name': name, 'price': price, 'qty': 1});
  }

  static void removeFromCart(String name) {
    cart.removeWhere((item) => item['name'] == name);
  }
}

String formatRs(dynamic amount) {
  double value = amount is int ? amount.toDouble() : amount;
  return value.toStringAsFixed(0);
}