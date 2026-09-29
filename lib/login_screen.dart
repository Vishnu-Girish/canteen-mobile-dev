import 'package:flutter/material.dart';
import 'app_data.dart';
import 'home_screen.dart';
import 'transitions.dart';

class LoginScreen extends StatefulWidget {
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  String error = '';

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF141414),
      body: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('CanteenGo', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            SizedBox(height: 40),
            TextField(
              controller: userCtrl,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(labelText: 'Username (admin / student)', labelStyle: TextStyle(color: Colors.white54), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24))),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passCtrl,
              obscureText: true,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(labelText: 'Password (admin / student)', labelStyle: TextStyle(color: Colors.white54), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24))),
            ),
            SizedBox(height: 8),
            Text(error, style: TextStyle(color: Colors.redAccent)),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, padding: EdgeInsets.all(16)),
              onPressed: () {
                if (userCtrl.text == 'admin' && passCtrl.text == 'admin') {
                  AppData.currentUserRole = 'admin';
                  Navigator.pushReplacement(context, fadeRoute(HomeScreen()));
                } else if (userCtrl.text == 'student' && passCtrl.text == 'student') {
                  AppData.currentUserRole = 'student';
                  Navigator.pushReplacement(context, fadeRoute(HomeScreen()));
                } else {
                  setState(() => error = 'Invalid credentials');
                }
              },
              child: Text('Login', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}