import 'package:flutter/material.dart';
import 'app_data.dart';
import 'orders_screen.dart';
import 'transitions.dart';

class CheckoutScreen extends StatefulWidget {
  State<CheckoutScreen> createState() => CheckoutScreenState();
}

class CheckoutScreenState extends State<CheckoutScreen> {
  bool closeEnough = false;

  Widget build(BuildContext context) {
    double total = AppData.cartTotal();

    return Scaffold(
      backgroundColor: Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: Color(0xFF141414),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Checkout', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: AppData.cart.map((item) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('${item['name']} x${item['qty']}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      Text('Rs ${formatRs(item['price'] * item['qty'])}', style: TextStyle(color: Colors.white)),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        onPressed: () {
                          setState(() {
                            AppData.removeFromCart(item['name']);
                          });
                        },
                      )
                    ],
                  ),
                );
              }).toList(),
            ),
            Divider(color: Colors.white12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Rs ${formatRs(total)}', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 20),
            closeEnough
                ? SizedBox()
                : GestureDetector(
                    onTap: () => setState(() => closeEnough = true),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Color(0xFF3D2A0F), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.orange, size: 18),
                          SizedBox(width: 8),
                          Expanded(child: Text('120m away — get closer to pay (tap to simulate)', style: TextStyle(color: Colors.orange))),
                        ],
                      ),
                    ),
                  ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: (closeEnough && total > 0 && AppData.walletBalance >= total)
                  ? () {
                      setState(() {
                        AppData.orders.insert(0, {
                          'id': AppData.nextOrderId++,
                          'status': 'Preparing',
                          'items': AppData.cart.map((i) => '${i['name']} x${i['qty']}').join(', '),
                          'total': total,
                        });
                        AppData.walletBalance -= total;
                        AppData.cart.clear();
                      });
                      Navigator.pushReplacement(context, fadeRoute(OrdersScreen()));
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: closeEnough ? Colors.white : Colors.white12,
                padding: EdgeInsets.all(14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'Pay from wallet (Rs ${formatRs(AppData.walletBalance)})',
                style: TextStyle(color: closeEnough ? Colors.black : Colors.white38, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}