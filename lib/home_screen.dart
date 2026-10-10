import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_data.dart';
import 'menu_screen.dart';
import 'orders_screen.dart';
import 'create_canteen_screen.dart';
import 'login_screen.dart';
import 'transitions.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int selectedTab = 0;

  void _showWalletDialog(BuildContext context) {
    final rollNoCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    // Regex pattern matching: CB.SC.U4 [3 letters/chars] [5 digits]
    final RegExp rollNoRegex = RegExp(r'^CB\.SC\.U4[A-Za-z]{3}\d{5}$');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF494D5F),
        title: const Text('Add Funds to Wallet', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: rollNoCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Roll No (CB.SC.U4xxxyyyyy)',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Amount (Rs)',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA0D2EB)),
            onPressed: () {
              String rollNo = rollNoCtrl.text.trim();
              if (!rollNoRegex.hasMatch(rollNo)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid roll number format! Must match CB.SC.U4xxxyyyyy')),
                );
                return;
              }

              double? amt = double.tryParse(amountCtrl.text);
              if (amt == null || amt <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter a valid amount.')),
                );
                return;
              }

              setState(() {
                AppData.walletBalance += amt;
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Successfully added Rs ${formatRs(amt)} to wallet!')),
              );
            },
            child: const Text('Add Funds', style: TextStyle(color: Color(0xFF494D5F))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = AppData.currentUserRole == 'admin';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppData.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        body: selectedTab == 0 ? SafeArea(child: buildHomeTab(context, isAdmin)) : OrdersScreen(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedTab,
          onTap: (index) => setState(() => selectedTab = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Canteens'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Orders'),
          ],
        ),
      ),
    );
  }

  Widget buildHomeTab(BuildContext context, bool isAdmin) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF8458B3).withOpacity(0.6),
                const Color(0xFF8458B3).withOpacity(0.5),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Canteens', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      if (!isAdmin)
                        IconButton(
                          icon: const Icon(Icons.account_balance_wallet, color: Color(0xFFA0D2EB)),
                          tooltip: 'Add Funds',
                          onPressed: () => _showWalletDialog(context),
                        ),
                      IconButton(
                        icon: Icon(AppData.isDarkMode ? Icons.light_mode : Icons.dark_mode, color: const Color(0xFFE5EAF5)),
                        onPressed: () {
                          setState(() {
                            AppData.isDarkMode = !AppData.isDarkMode;
                          });
                        },
                      ),
                      if (isAdmin)
                        OutlinedButton(
                          onPressed: () => Navigator.push(context, fadeRoute(CreateCanteenScreen())),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE5EAF5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('+ Create', style: TextStyle(color: Colors.white)),
                        ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Color(0xFFE5EAF5)),
                        onPressed: () {
                          AppData.currentUserRole = '';
                          Navigator.pushReplacement(context, fadeRoute(const LoginScreen()));
                        },
                      )
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('canteens').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No canteens found.', style: TextStyle(color: Colors.white)));
                    }
                    
                    var docs = snapshot.data!.docs;
                    return ListView.separated(
                      itemCount: docs.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        var data = docs[index].data() as Map<String, dynamic>;
                        String id = docs[index].id;
                        String name = data['name'] ?? 'Unknown';
                        String info = data['info'] ?? '';
                        List<Map<String, dynamic>> menu = List<Map<String, dynamic>>.from(data['menu'] ?? []);
                        
                        return canteenCard(context, id, name, info, menu, isAdmin);
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget canteenCard(BuildContext context, String docId, String name, String info, List<Map<String, dynamic>> menu, bool isAdmin) {
    return GestureDetector(
      onTap: () => Navigator.push(context, fadeRoute(MenuScreen(canteenName: name, menuItems: menu))),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF494D5F).withOpacity(0.85), border: Border.all(color: const Color(0xFFD0BDF4)), borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(info, style: const TextStyle(color: Color(0xFFE5EAF5), fontSize: 13)),
              ],
            ),
            if (isAdmin)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () {
                  FirebaseFirestore.instance.collection('canteens').doc(docId).delete();
                }
              )
          ],
        ),
      ),
    );
  }
}