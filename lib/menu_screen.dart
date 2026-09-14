import 'package:flutter/material.dart';
import 'app_data.dart';
import 'checkout_screen.dart';
import 'transitions.dart';

// Screen 2 from the diagram: Canteen menu + cart.
class MenuScreen extends StatefulWidget {
  final String canteenName;

  MenuScreen({required this.canteenName});

  State<MenuScreen> createState() {
    return MenuScreenState();
  }
}

class MenuScreenState extends State<MenuScreen> {
  List<Map<String, dynamic>> menuItems = [
    {'name': 'Idli sambar', 'price': 30, 'available': true},
    {'name': 'Veg puffs', 'price': 20, 'available': true},
    {'name': 'Samosa', 'price': 15, 'available': false},
  ];

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: Color(0xFF141414),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          widget.canteenName + ' menu',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: menuItems.length,
                separatorBuilder: (context, index) {
                  return Divider(color: Colors.white12);
                },
                itemBuilder: (context, index) {
                  var item = menuItems[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      item['name'],
                      style: TextStyle(
                        color: item['available'] ? Colors.white : Colors.white38,
                        fontWeight: FontWeight.bold,
                        decoration: item['available']
                            ? TextDecoration.none
                            : TextDecoration.lineThrough,
                      ),
                    ),
                    trailing: item['available']
                        ? Text(
                            'Rs ' + formatRs(item['price']),
                            style: TextStyle(color: Colors.white),
                          )
                        : Text('Sold out', style: TextStyle(color: Colors.redAccent)),
                    onTap: item['available']
                        ? () {
                            setState(() {
                              AppData.cart.add({
                                'name': item['name'],
                                'price': item['price'],
                              });
                            });
                          }
                        : null,
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cart: ' + AppData.cart.length.toString() + ' items',
                  style: TextStyle(color: Colors.white70),
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(context, fadeRoute(CheckoutScreen()));
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('View cart', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
