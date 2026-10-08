import 'package:flutter/material.dart';
import 'app_data.dart';
import 'home_screen.dart';
import 'transitions.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Map<String, Map<String, String>> credentials = {
    'student': {'username': 'student', 'password': 'student123'},
    'admin': {'username': 'admin', 'password': 'admin123'},
  };

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  String selectedRole = 'student';
  bool obscurePassword = true;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() {
    final roleCredentials = credentials[selectedRole]!;
    final isValid = usernameController.text.trim() == roleCredentials['username'] &&
        passwordController.text == roleCredentials['password'];

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect username or password.')),
      );
      return;
    }

    AppData.currentUserRole = selectedRole;
    Navigator.pushReplacement(context, fadeRoute(HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.storefront, size: 48, color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'Canteen App',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Sign in as',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'student', child: Text('Student')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  ],
                  onChanged: (role) {
                    if (role != null) {
                      setState(() {
                        selectedRole = role;
                        usernameController.clear();
                        passwordController.clear();
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: usernameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  onSubmitted: (_) => login(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      tooltip: obscurePassword ? 'Show password' : 'Hide password',
                      onPressed: () => setState(() => obscurePassword = !obscurePassword),
                      icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: login,
                  child: const Text('Log in'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}