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

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning, Chief ☀️';
    if (hour < 17) return 'Good Afternoon ☕';
    return 'Good Evening 🌙';
  }

  void _showWalletDialog(BuildContext context) {
    final rollNoCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final RegExp rollNoRegex = RegExp(r'^CB\.SC\.U4[A-Za-z]{3}\d{5}$');
    String? rollError;
    String? amountError;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF494D5F),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Top-Up Wallet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: rollNoCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Roll No (CB.SC.U4xxxyyyyy)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.black12,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              if (rollError != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.amberAccent, size: 18),
                    const SizedBox(width: 6),
                    Expanded(child: Text(rollError!, style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold))),
                  ],
                ),
              ],
              const SizedBox(height: 14),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Amount (Max Rs 500)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.black12,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              if (amountError != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.amberAccent, size: 18),
                    const SizedBox(width: 6),
                    Expanded(child: Text(amountError!, style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold))),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA0D2EB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () {
                String rollNo = rollNoCtrl.text.trim();
                double? amt = double.tryParse(amountCtrl.text);

                bool hasError = false;
                setDialogState(() {
                  if (!rollNoRegex.hasMatch(rollNo)) {
                    rollError = 'Invalid format! Must match CB.SC.U4xxxyyyyy';
                    hasError = true;
                  } else {
                    rollError = null;
                  }

                  if (amt == null || amt <= 0 || amt > 500) {
                    amountError = 'Max limit is Rs 500 per transaction.';
                    hasError = true;
                  } else {
                    amountError = null;
                  }
                });

                if (hasError) return;

                setState(() {
                  AppData.walletBalance += amt!;
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added Rs ${formatRs(amt!)} to wallet successfully!'), backgroundColor: Colors.green),
                );
              },
              child: const Text('Proceed', style: TextStyle(color: Color(0xFF494D5F), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
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
          selectedItemColor: const Color(0xFFA0D2EB),
          unselectedItemColor: Colors.white60,
          backgroundColor: const Color(0xFF494D5F),
          onTap: (index) => setState(() => selectedTab = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.storefront_rounded), label: 'Canteens'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Live Orders'),
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
                const Color(0xFF8458B3).withOpacity(0.75),
                const Color(0xFF494D5F).withOpacity(0.9),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header & Greeting
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: const TextStyle(color: Color(0xFFA0D2EB), fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Campus Canteens',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (!isAdmin)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
                          child: IconButton(
                            icon: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFFA0D2EB)),
                            tooltip: 'Add Funds',
                            onPressed: () => _showWalletDialog(context),
                          ),
                        ),
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
                        child: IconButton(
                          icon: Icon(AppData.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: Colors.white70),
                          onPressed: () => setState(() => AppData.isDarkMode = !AppData.isDarkMode),
                        ),
                      ),
                      if (isAdmin)
                        OutlinedButton(
                          onPressed: () => Navigator.push(context, fadeRoute(CreateCanteenScreen())),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFA0D2EB)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('+ Create', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                        onPressed: () {
                          AppData.currentUserRole = '';
                          Navigator.pushReplacement(context, fadeRoute(const LoginScreen()));
                        },
                      )
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('canteens').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFFA0D2EB)));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No canteens active right now.', style: TextStyle(color: Colors.white70)));
                    }
                    
                    var docs = snapshot.data!.docs;
                    return ListView.separated(
                      itemCount: docs.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 14),
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
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF494D5F).withOpacity(0.85),
          border: Border.all(color: const Color(0xFFD0BDF4).withOpacity(0.5)),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(info, style: const TextStyle(color: Color(0xFFE5EAF5), fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFA0D2EB), size: 18),
            if (isAdmin)
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                onPressed: () => FirebaseFirestore.instance.collection('canteens').doc(docId).delete(),
              )
          ],
        ),
      ),
    );
  }
}