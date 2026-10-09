import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateCanteenScreen extends StatefulWidget {
  @override
  State<CreateCanteenScreen> createState() => _CreateCanteenScreenState();
}

class _CreateCanteenScreenState extends State<CreateCanteenScreen> {
  final nameCtrl = TextEditingController();
  bool isSaving = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    super.dispose();
  }

  Future<void> saveCanteen() async {
    if (nameCtrl.text.trim().isEmpty) return;
    
    setState(() => isSaving = true);
    
    try {
      await FirebaseFirestore.instance.collection('canteens').add({
        'name': nameCtrl.text.trim(),
        'info': 'Newly created',
        'menu': [],
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF494D5F),
      appBar: AppBar(
        title: const Text('Create Canteen', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF494D5F),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Canteen Name',
                labelStyle: TextStyle(color: Color(0xFFE5EAF5)),
                filled: true,
                fillColor: Color(0xFF8458B3),
                border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(8))),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isSaving ? null : saveCanteen,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA0D2EB),
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Color(0xFF494D5F)))
                  : const Text('Save Canteen', style: TextStyle(color: Color(0xFF494D5F), fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}