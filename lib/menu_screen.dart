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
  final newItemCtrl = TextEditingController();
  final newPriceCtrl = TextEditingController();

  void showEditDialog(Map<String, dynamic> item) {
    TextEditingController priceUpdateCtrl = TextEditingController(text: item['price'].toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1E1E1E),
          title: Text('Edit ${item['name']}', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: priceUpdateCtrl,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(labelText: 'New Price (or Discount)', labelStyle: TextStyle(color: Colors.white54)),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() => AppData.toggleItemAvailability(widget.canteenName, item['name']));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: item['available'] ? Colors.redAccent : Colors.green),
                child: Text(item['available'] ? 'Mark Sold Out' : 'Mark Available', style: TextStyle(color: Colors.white)),
              )
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: Colors.white54))),
            TextButton(
              onPressed: () {
                if (priceUpdateCtrl.text.isNotEmpty) {
                  setState(() => AppData.updateItemPrice(widget.canteenName, item['name'], double.parse(priceUpdateCtrl.text)));
                }
                Navigator.pop(context);
              },
              child: Text('Save Price', style: TextStyle(color: Colors.white)),
            )
          ],
        );
      },
    );
  }

  void showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1E1E1E),
          title: Text('Add Menu Item', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: newItemCtrl, style: TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Item Name', labelStyle: TextStyle(color: Colors.white54))),
              TextField(controller: newPriceCtrl, keyboardType: TextInputType.number, style: TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Price', labelStyle: TextStyle(color: Colors.white54))),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: Colors.white54))),
            TextButton(
              onPressed: () {
                if (newItemCtrl.text.isNotEmpty && newPriceCtrl.text.isNotEmpty) {
                  setState(() => AppData.addMenuItem(widget.canteenName, newItemCtrl.text, double.parse(newPriceCtrl.text)));
                  newItemCtrl.clear();
                  newPriceCtrl.clear();
                }
                Navigator.pop(context);
              },
              child: Text('Add', style: TextStyle(color: Colors.white)),
            )
          ],
        );
      },
    );
  }

  Widget build(BuildContext context) {
    bool isAdmin = AppData.currentUserRole == 'admin';
    int totalItems = AppData.cart.fold(0, (sum, item) => sum + (item['qty'] as int));

    return Scaffold(
      backgroundColor: Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: Color(0xFF141414),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('${widget.canteenName} menu', style: TextStyle(color: Colors.white)),
        actions: [
          if (isAdmin)
            IconButton(icon: Icon(Icons.add), onPressed: showAddItemDialog)
        ],
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
                    onTap: isAdmin
                        ? () => showEditDialog(item)
                        : (item['available']
                            ? () => setState(() => AppData.addToCart(item['name'], item['price']))
                            : null),
                  );
                },
              ),
            ),
            if (!isAdmin)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Cart: $totalItems items', style: TextStyle(color: Colors.white70)),
                  OutlinedButton(
                    onPressed: totalItems > 0 ? () => Navigator.push(context, fadeRoute(CheckoutScreen())).then((_) => setState(() {})) : null,
                    style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
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