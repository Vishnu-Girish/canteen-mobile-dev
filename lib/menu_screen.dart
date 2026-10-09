import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_data.dart';
import 'checkout_screen.dart';
import 'transitions.dart';

class MenuScreen extends StatefulWidget {
  final String canteenName;
  final List<dynamic> menuItems;

  const MenuScreen({required this.canteenName, required this.menuItems, super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  void _showAddItemDialog(String docId, List currentMenu) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF494D5F),
        title: const Text('Add Item', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: Colors.white70))),
            TextField(controller: priceCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Price', labelStyle: TextStyle(color: Colors.white70))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA0D2EB)),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && priceCtrl.text.isNotEmpty) {
                final newItem = {'name': nameCtrl.text, 'price': double.parse(priceCtrl.text), 'available': true};
                FirebaseFirestore.instance.collection('canteens').doc(docId).update({
                  'menu': FieldValue.arrayUnion([newItem])
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add', style: TextStyle(color: Color(0xFF494D5F))),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = AppData.currentUserRole == 'admin';

    return Scaffold(
      backgroundColor: const Color(0xFF494D5F),
      appBar: AppBar(
        title: Text('${widget.canteenName} Menu', style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF494D5F),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('canteens').where('name', isEqualTo: widget.canteenName).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: CircularProgressIndicator(color: Colors.white));
          
          var doc = snapshot.data!.docs.first;
          var menu = List<Map<String, dynamic>>.from(doc['menu'] ?? []);

          if (menu.isEmpty) return const Center(child: Text('No items yet.', style: TextStyle(color: Colors.white)));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: menu.length,
            itemBuilder: (context, index) {
              var item = menu[index];
              return Card(
                color: const Color(0xFF8458B3),
                child: ListTile(
                  title: Text(item['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('Rs ${item['price']}', style: const TextStyle(color: Colors.white70)),
                  trailing: isAdmin 
                    ? IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          FirebaseFirestore.instance.collection('canteens').doc(doc.id).update({
                            'menu': FieldValue.arrayRemove([item])
                          });
                        },
                      )
                    : IconButton(
                        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
                        onPressed: () {
                          setState(() => AppData.addToCart(item['name'], item['price']));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item['name']} added.')));
                        },
                      ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: isAdmin
          ? StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('canteens').where('name', isEqualTo: widget.canteenName).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox();
                return FloatingActionButton(
                  onPressed: () => _showAddItemDialog(snapshot.data!.docs.first.id, snapshot.data!.docs.first['menu']),
                  backgroundColor: const Color(0xFF8458B3),
                  child: const Icon(Icons.add, color: Colors.white),
                );
              }
            )
          : FloatingActionButton.extended(
              onPressed: () => Navigator.push(context, fadeRoute(CheckoutScreen())).then((_) => setState(() {})),
              backgroundColor: const Color(0xFFA0D2EB),
              label: Text('Cart (Rs ${formatRs(AppData.cartTotal())})', style: const TextStyle(color: Color(0xFF494D5F), fontWeight: FontWeight.bold)),
              icon: const Icon(Icons.shopping_cart, color: Color(0xFF494D5F)),
            ),
    );
  }
}