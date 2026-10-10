import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
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
  File? _pickedImage;
  String searchQuery = '';
  String selectedCategory = 'All';
  final List<String> categories = ['All', 'Snacks', 'Meals', 'Beverages'];

  Future<void> _pickImage(StateSetter setDialogState) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 30);
    if (pickedFile != null) {
      setDialogState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  void _showAddItemDialog(String docId) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String categoryChoice = 'Snacks';
    _pickedImage = null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF494D5F),
          title: const Text('Add Menu Item', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Item Name', labelStyle: TextStyle(color: Colors.white70))),
                TextField(controller: priceCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Price (Rs)', labelStyle: TextStyle(color: Colors.white70))),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: categoryChoice,
                  dropdownColor: const Color(0xFF8458B3),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Category', labelStyle: TextStyle(color: Colors.white70)),
                  items: categories.where((c) => c != 'All').map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (val) => setDialogState(() => categoryChoice = val!),
                ),
                const SizedBox(height: 16),
                _pickedImage != null
                    ? Image.file(_pickedImage!, height: 80, width: 80, fit: BoxFit.cover)
                    : const Text('No image selected', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8458B3)),
                  onPressed: () => _pickImage(setDialogState),
                  icon: const Icon(Icons.photo, color: Colors.white),
                  label: const Text('Pick from Gallery', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA0D2EB)),
              onPressed: () async {
                if (nameCtrl.text.isNotEmpty && priceCtrl.text.isNotEmpty) {
                  String base64Image = '';
                  if (_pickedImage != null) {
                    List<int> imageBytes = await _pickedImage!.readAsBytes();
                    base64Image = base64Encode(imageBytes);
                  }

                  final newItem = {
                    'name': nameCtrl.text.trim(),
                    'price': double.parse(priceCtrl.text),
                    'category': categoryChoice,
                    'imageBase64': base64Image,
                    'available': true,
                  };

                  await FirebaseFirestore.instance.collection('canteens').doc(docId).update({
                    'menu': FieldValue.arrayUnion([newItem])
                  });
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('Add', style: TextStyle(color: Color(0xFF494D5F))),
            )
          ],
        ),
      ),
    );
  }

  void _updateItemAvailability(String docId, List menu, Map item, bool newStatus) async {
    await FirebaseFirestore.instance.collection('canteens').doc(docId).update({
      'menu': FieldValue.arrayRemove([item])
    });
    item['available'] = newStatus;
    await FirebaseFirestore.instance.collection('canteens').doc(docId).update({
      'menu': FieldValue.arrayUnion([item])
    });
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

          // Filter by search query and category
          var filteredMenu = menu.where((item) {
            String name = item['name']?.toLowerCase() ?? '';
            String cat = item['category'] ?? 'Snacks';
            bool matchesSearch = name.contains(searchQuery.toLowerCase());
            bool matchesCat = selectedCategory == 'All' || cat == selectedCategory;
            return matchesSearch && matchesCat;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  onChanged: (val) => setState(() => searchQuery = val),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Search items...',
                    hintStyle: TextStyle(color: Colors.white54),
                    prefixIcon: Icon(Icons.search, color: Colors.white54),
                    filled: true,
                    fillColor: Color(0xFF8458B3),
                    border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(8))),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    String cat = categories[index];
                    bool isSelected = selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: const Color(0xFFA0D2EB),
                        backgroundColor: const Color(0xFF8458B3),
                        labelStyle: TextStyle(color: isSelected ? const Color(0xFF494D5F) : Colors.white, fontWeight: FontWeight.bold),
                        onSelected: (_) => setState(() => selectedCategory = cat),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filteredMenu.isEmpty
                    ? const Center(child: Text('No items found.', style: TextStyle(color: Colors.white54)))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: filteredMenu.length,
                        itemBuilder: (context, index) {
                          var item = filteredMenu[index];
                          String base64Str = item['imageBase64'] ?? '';
                          bool isAvailable = item['available'] ?? true;

                          return Opacity(
                            opacity: isAvailable ? 1.0 : 0.5,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF8458B3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isAvailable ? const Color(0xFFD0BDF4) : Colors.redAccent),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                          child: base64Str.isNotEmpty
                                              ? Image.memory(base64Decode(base64Str), fit: BoxFit.cover)
                                              : Container(color: Colors.black12, child: const Icon(Icons.fastfood, color: Colors.white, size: 40)),
                                        ),
                                        if (!isAvailable)
                                          Container(
                                            color: Colors.black54,
                                            alignment: Alignment.center,
                                            child: const Text('SOLD OUT', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 2),
                                        Text('Rs ${formatRs(item['price'])}', style: const TextStyle(color: Color(0xFFA0D2EB), fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                    child: isAdmin
                                        ? Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              IconButton(
                                                constraints: const BoxConstraints(),
                                                padding: EdgeInsets.zero,
                                                icon: Icon(isAvailable ? Icons.visibility : Icons.visibility_off, color: Colors.white, size: 18),
                                                onPressed: () => _updateItemAvailability(doc.id, menu, item, !isAvailable),
                                              ),
                                              IconButton(
                                                constraints: const BoxConstraints(),
                                                padding: EdgeInsets.zero,
                                                icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18),
                                                onPressed: () {
                                                  FirebaseFirestore.instance.collection('canteens').doc(doc.id).update({
                                                    'menu': FieldValue.arrayRemove([item])
                                                  });
                                                },
                                              ),
                                            ],
                                          )
                                        : ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isAvailable ? const Color(0xFFA0D2EB) : Colors.grey,
                                              padding: EdgeInsets.zero,
                                              minimumSize: const Size(double.infinity, 28),
                                            ),
                                            onPressed: isAvailable
                                                ? () {
                                                    setState(() => AppData.addToCart(item['name'], item['price']));
                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item['name']} added.')));
                                                  }
                                                : null,
                                            child: Text(isAvailable ? 'Add to Cart' : 'Unavailable', style: const TextStyle(color: Color(0xFF494D5F), fontSize: 11, fontWeight: FontWeight.bold)),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: isAdmin
          ? StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('canteens').where('name', isEqualTo: widget.canteenName).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox();
                return FloatingActionButton(
                  onPressed: () => _showAddItemDialog(snapshot.data!.docs.first.id),
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