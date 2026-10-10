import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_data.dart';

class OrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool isAdmin = AppData.currentUserRole == 'admin';

    return Scaffold(
      backgroundColor: const Color(0xFF494D5F),
      appBar: AppBar(
        title: Text(isAdmin ? 'Manage Orders' : 'Live Order Tracking', style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF494D5F),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No active orders.', style: TextStyle(color: Colors.white)));
          }

          var docs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var doc = docs[index];
              var data = doc.data() as Map<String, dynamic>;
              String status = data['status'] ?? 'Preparing';

              Color statusColor = Colors.orangeAccent;
              if (status == 'Ready') statusColor = Colors.blueAccent;
              if (status == 'Completed') statusColor = Colors.greenAccent;

              return Card(
                color: const Color(0xFF8458B3),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Order #${doc.id.substring(0, 5)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.2),
                              border: Border.all(color: statusColor),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(data['items'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text('Total: Rs ${formatRs(data['total'] ?? 0)}', style: const TextStyle(color: Color(0xFFA0D2EB), fontSize: 13)),
                      if (isAdmin) ...[
                        const Divider(color: Color(0xFFD0BDF4)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (status == 'Preparing')
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                                onPressed: () {
                                  FirebaseFirestore.instance.collection('orders').doc(doc.id).update({'status': 'Ready'});
                                },
                                child: const Text('Mark Ready', style: TextStyle(color: Colors.white, fontSize: 12)),
                              ),
                            if (status == 'Ready')
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
                                onPressed: () {
                                  FirebaseFirestore.instance.collection('orders').doc(doc.id).update({'status': 'Completed'});
                                },
                                child: const Text('Mark Completed', style: TextStyle(color: Colors.black, fontSize: 12)),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}