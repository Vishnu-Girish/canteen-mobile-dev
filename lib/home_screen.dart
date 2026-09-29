import 'package:flutter/material.dart';
import 'app_data.dart';
import 'menu_screen.dart';
import 'orders_screen.dart';
import 'create_canteen_screen.dart';
import 'transitions.dart';

class HomeScreen extends StatefulWidget {
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int selectedTab = 0;

  Widget build(BuildContext context) {
    bool isAdmin = AppData.currentUserRole == 'admin';

    return Scaffold(
      body: selectedTab == 0 ? SafeArea(child: buildHomeTab(context, isAdmin)) : OrdersScreen(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white38,
        currentIndex: selectedTab,
        onTap: (index) => setState(() => selectedTab = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Canteens'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Orders'),
        ],
      ),
    );
  }

  Widget buildHomeTab(BuildContext context, bool isAdmin) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Canteens', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              if (isAdmin)
                OutlinedButton(
                  onPressed: () => Navigator.push(context, fadeRoute(CreateCanteenScreen())).then((_) => setState(() {})),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('+ Create', style: TextStyle(color: Colors.white)),
                ),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: AppData.canteens.length,
              separatorBuilder: (context, index) => SizedBox(height: 12),
              itemBuilder: (context, index) {
                var c = AppData.canteens[index];
                return canteenCard(context, c['name'], c['info'], c['menu'], isAdmin);
              },
            ),
          )
        ],
      ),
    );
  }

  Widget canteenCard(BuildContext context, String name, String info, List<Map<String, dynamic>> menu, bool isAdmin) {
    return GestureDetector(
      onTap: () => Navigator.push(context, fadeRoute(MenuScreen(canteenName: name, menuItems: menu))).then((_) => setState(() {})),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(color: Color(0xFF1E1E1E), border: Border.all(color: Colors.white12), borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(info, style: TextStyle(color: Colors.white54, fontSize: 13)),
              ],
            ),
            if (isAdmin)
              IconButton(
                icon: Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => setState(() => AppData.deleteCanteen(name)),
              )
          ],
        ),
      ),
    );
  }
}