import 'package:flutter/material.dart';
import 'app_data.dart';
import 'checkout_screen.dart';
import 'transitions.dart';

class MenuScreen extends StatefulWidget {
  final String canteenName;
  final List<Map<String, dynamic>> menuItems;
  MenuScreen({required this.canteenName, required this.menuItems});
  State<MenuScreen> createState() => MenuScreenState();
}

class MenuScreenState extends State<MenuScreen> {
  Widget build(BuildContext context) {
    int totalItems = AppData.cart.fold(0, (sum, item) => sum + (item['qty'] as int));

    return Scaffold(
      backgroundColor: Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: Color(0xFF141414),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('${widget.canteenName} menu', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: widget.menuItems.length,
                separatorBuilder: (context, index) => Divider(color: Colors.white12),
                itemBuilder: (context, index) {
                  var item = widget.menuItems[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      item['name'],
                      style: TextStyle(
                        color: item['available'] ? Colors.white : Colors.white38,
                        fontWeight: FontWeight.bold,
                        decoration: item['available'] ? TextDecoration.none : TextDecoration.lineThrough,
                      ),
                    ),
                    trailing: item['available']
                        ? Text('Rs ${formatRs(item['price'])}', style: TextStyle(color: Colors.white))
                        : Text('Sold out', style: TextStyle(color: Colors.redAccent)),
                    onTap: item['available']
                        ? () {
                            setState(() {
                              AppData.addToCart(item['name'], item['price']);
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
                Text('Cart: $totalItems items', style: TextStyle(color: Colors.white70)),
                OutlinedButton(
                  onPressed: totalItems > 0
                      ? () => Navigator.push(context, fadeRoute(CheckoutScreen())).then((_) => setState(() {}))
                      : null,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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