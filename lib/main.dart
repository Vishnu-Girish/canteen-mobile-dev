import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Canteen App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF494D5F),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF494D5F),
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFFE5EAF5)),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF8458B3),
          selectedItemColor: Color(0xFFE5EAF5),
          unselectedItemColor: Color(0xFFD0BDF4),
        ),
      ),
      home: LoginScreen(),
    );
  }
}