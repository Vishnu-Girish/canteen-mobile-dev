import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF494D5F),
      appBar: AppBar(
        title: const Text('My Orders', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF494D5F),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.white));
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('No orders yet.', style: TextStyle(color: Colors.white)));

          var docs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              return Card(
                color: const Color(0xFF8458B3),
                child: ListTile(
                  title: Text(data['items'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('Total: Rs ${data['total']}', style: const TextStyle(color: Colors.white70)),
                  trailing: Text(data['status'] ?? '', style: const TextStyle(color: Color(0xFFA0D2EB), fontWeight: FontWeight.bold)),
                ),
              );
            },
          );
        }
      ),
    );
  }
}