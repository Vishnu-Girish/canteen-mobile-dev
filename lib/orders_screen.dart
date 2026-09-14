import 'package:flutter/material.dart';
import 'app_data.dart';

// Screen 4 from the diagram: Orders + wallet.
class OrdersScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: Color(0xFF141414),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Your orders', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: AppData.orders.length,
                separatorBuilder: (context, index) {
                  return Divider(color: Colors.white12);
                },
                itemBuilder: (context, index) {
                  var order = AppData.orders[index];
                  Color statusColor = order['status'] == 'Preparing'
                      ? Colors.greenAccent
                      : Colors.white38;
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #' + order['id'].toString(),
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              order['items'] + ' — Rs ' + formatRs(order['total']),
                              style: TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                        Text(order['status'], style: TextStyle(color: statusColor)),
                      ],
                    ),
                  );
                },
              ),
            ),
            Divider(color: Colors.white12),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Wallet balance', style: TextStyle(color: Colors.white70)),
                Text(
                  'Rs ' + formatRs(AppData.walletBalance),
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
