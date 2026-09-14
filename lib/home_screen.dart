import 'package:flutter/material.dart';
import 'menu_screen.dart';
import 'orders_screen.dart';
import 'transitions.dart';

// Screen 1 from the diagram: Home - canteen list.
// Also hosts the bottom nav bar so "Orders + wallet" (screen 4)
// is reachable at any time, not just after checkout.
class HomeScreen extends StatefulWidget {
  State<HomeScreen> createState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> {
  int selectedTab = 0;

  Widget build(BuildContext context) {
    return Scaffold(
      body: selectedTab == 0
          ? SafeArea(child: buildHomeTab(context))
          : OrdersScreen(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white38,
        currentIndex: selectedTab,
        onTap: (index) {
          setState(() {
            selectedTab = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Canteens',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
        ],
      ),
    );
  }

  Widget buildHomeTab(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Canteens',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('+ Create', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          SizedBox(height: 16),
          canteenCard(context, 'Main canteen', '120m away · open'),
          SizedBox(height: 12),
          canteenCard(context, 'Hostel mess', '400m away · open'),
          SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'Tap a canteen to view menu',
                style: TextStyle(color: Colors.white38),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget canteenCard(BuildContext context, String name, String info) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, fadeRoute(MenuScreen(canteenName: name)));
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF1E1E1E),
          border: Border.all(color: Colors.white12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(info, style: TextStyle(color: Colors.white54, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
