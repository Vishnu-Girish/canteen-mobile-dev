class AppData {
  static String currentUserRole = 'student'; // 'admin' or 'student'
  static List<Map<String, dynamic>> cart = [];
  static double walletBalance = 300;
  static int nextOrderId = 242;
  static List<Map<String, dynamic>> orders = [
    {'id': 241, 'status': 'Preparing', 'items': 'Idli sambar x1, veg puffs x1', 'total': 50},
    {'id': 238, 'status': 'Picked up', 'items': 'Idli sambar x1', 'total': 30},
  ];

  static List<Map<String, dynamic>> canteens = [
    {
      'name': 'Main canteen',
      'info': '120m away · open',
      'menu': [
        {'name': 'Idli sambar', 'price': 30.0, 'available': true},
        {'name': 'Veg puffs', 'price': 20.0, 'available': true},
        {'name': 'Samosa', 'price': 15.0, 'available': false},
      ]
    },
    {
      'name': 'Hostel mess',
      'info': '400m away · open',
      'menu': [
        {'name': 'Meals', 'price': 50.0, 'available': true},
      ]
    }
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

  static void deleteCanteen(String name) {
    canteens.removeWhere((c) => c['name'] == name);
  }

  static void addMenuItem(String canteenName, String itemName, double price) {
    var canteen = canteens.firstWhere((c) => c['name'] == canteenName);
    canteen['menu'].add({'name': itemName, 'price': price, 'available': true});
  }

  static void updateItemPrice(String canteenName, String itemName, double newPrice) {
    var canteen = canteens.firstWhere((c) => c['name'] == canteenName);
    var item = (canteen['menu'] as List).firstWhere((i) => i['name'] == itemName);
    item['price'] = newPrice;
  }

  static void toggleItemAvailability(String canteenName, String itemName) {
    var canteen = canteens.firstWhere((c) => c['name'] == canteenName);
    var item = (canteen['menu'] as List).firstWhere((i) => i['name'] == itemName);
    item['available'] = !item['available'];
  }
}

String formatRs(dynamic amount) {
  double value = amount is int ? amount.toDouble() : amount;
  return value.toStringAsFixed(0);
}