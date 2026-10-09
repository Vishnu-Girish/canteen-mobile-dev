class AppData {
  static String currentUserRole = 'student'; // Populated by Firestore on login
  static List<Map<String, dynamic>> cart = [];
  static double walletBalance = 300; // We will move this to the DB later

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