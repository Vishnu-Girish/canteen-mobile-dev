// This file holds all the "shared" data for the app.
// Kept as one simple static class so every screen can read/update
// the same cart, orders and wallet balance without extra packages.

class AppData {
  static List<Map<String, dynamic>> cart = [
    {'name': 'Idli sambar', 'price': 30},
    {'name': 'Veg puffs', 'price': 20},
  ];

  static double walletBalance = 300;

  static int nextOrderId = 242;

  static List<Map<String, dynamic>> orders = [
    {
      'id': 241,
      'status': 'Preparing',
      'items': 'Idli sambar, veg puffs',
      'total': 50,
    },
    {
      'id': 238,
      'status': 'Picked up',
      'items': 'Idli sambar',
      'total': 30,
    },
  ];

  static double cartTotal() {
    double total = 0;
    for (var item in cart) {
      total = total + item['price'];
    }
    return total;
  }
}

// Small helper so every screen can print prices the same way,
// without decimals, whether the number is an int or a double.
String formatRs(dynamic amount) {
  double value = 0;
  if (amount is int) {
    value = amount.toDouble();
  } else {
    value = amount;
  }
  return value.toStringAsFixed(0);
}
