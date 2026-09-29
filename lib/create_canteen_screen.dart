import 'package:flutter/material.dart';
import 'app_data.dart';

class CreateCanteenScreen extends StatefulWidget {
  State<CreateCanteenScreen> createState() => CreateCanteenScreenState();
}

class CreateCanteenScreenState extends State<CreateCanteenScreen> {
  final nameCtrl = TextEditingController();
  final itemCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  List<Map<String, dynamic>> pendingMenu = [];

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: Color(0xFF141414),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Create Canteen', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(labelText: 'Canteen Name', labelStyle: TextStyle(color: Colors.white54), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24))),
            ),
            SizedBox(height: 20),
            Text('Menu Items', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: TextField(controller: itemCtrl, style: TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Item name', hintStyle: TextStyle(color: Colors.white38)))),
                SizedBox(width: 10),
                SizedBox(width: 80, child: TextField(controller: priceCtrl, keyboardType: TextInputType.number, style: TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Price', hintStyle: TextStyle(color: Colors.white38)))),
                IconButton(
                  icon: Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    if (itemCtrl.text.isNotEmpty && priceCtrl.text.isNotEmpty) {
                      setState(() {
                        pendingMenu.add({'name': itemCtrl.text, 'price': double.parse(priceCtrl.text), 'available': true});
                        itemCtrl.clear();
                        priceCtrl.clear();
                      });
                    }
                  },
                )
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: pendingMenu.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(pendingMenu[index]['name'], style: TextStyle(color: Colors.white)),
                    trailing: Text('Rs ${formatRs(pendingMenu[index]['price'])}', style: TextStyle(color: Colors.white)),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty) {
                  AppData.canteens.add({'name': nameCtrl.text, 'info': '0m away · newly created', 'menu': pendingMenu});
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, minimumSize: Size(double.infinity, 50)),
              child: Text('Save Canteen', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}