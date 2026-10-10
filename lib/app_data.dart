class AppData {
  static String currentUserRole = '';
  static double walletBalance = 500.0;
  static bool isDarkMode = true;
  static List<Map<String, dynamic>> cart = [];

  static void addToCart(String name, double price) {
    for (var item in cart) {
      if (item['name'] == name) {
        item['qty']++;
        return;
      }
    }
    cart.add({'name': name, 'price': price, 'qty': 1});
  }

  static void removeFromCart(String name) {
    cart.removeWhere((item) => item['name'] == name);
  }

  static double cartTotal() {
    double total = 0;
    for (var item in cart) {
      total += (item['price'] * item['qty']);
    }
    return total;
  }
}

String formatRs(double val) {
  if (val == val.roundToDouble()) {
    return val.toInt().toString();
  }
  return val.toStringAsFixed(2);
}