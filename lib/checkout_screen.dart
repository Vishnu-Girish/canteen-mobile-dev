import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_data.dart';
import 'orders_screen.dart';
import 'transitions.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  State<CheckoutScreen> createState() => CheckoutScreenState();
}

class CheckoutScreenState extends State<CheckoutScreen> {
  bool closeEnough = false;
  bool isChecking = false;
  String locationMessage = 'Tap to verify GPS proximity (Must be inside campus < 800m)';

  final double targetLat = 10.904157;
  final double targetLng = 76.898561;

  Future<void> verifyProximity() async {
    setState(() {
      isChecking = true;
      locationMessage = 'Acquiring GPS signal...';
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        isChecking = false;
        locationMessage = 'Location services disabled.';
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() {
          isChecking = false;
          locationMessage = 'Location permission denied.';
        });
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    double distance = Geolocator.distanceBetween(
      position.latitude, 
      position.longitude, 
      targetLat, 
      targetLng
    );

    setState(() {
      isChecking = false;
      if (distance <= 800) {
        closeEnough = true;
      } else {
        locationMessage = 'Too far. You are ${distance.toStringAsFixed(0)}m away from campus.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double total = AppData.cartTotal();

    return Scaffold(
      backgroundColor: const Color(0xFF494D5F),
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF494D5F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: AppData.cart.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('${item['name']} x${item['qty']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      Text('Rs ${formatRs(item['price'] * item['qty'])}', style: const TextStyle(color: Colors.white)),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        onPressed: () {
                          setState(() {
                            AppData.removeFromCart(item['name']);
                          });
                        },
                      )
                    ],
                  ),
                );
              }).toList(),
            ),
            const Divider(color: Color(0xFFD0BDF4)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Rs ${formatRs(total)}', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            if (!closeEnough) ...[
              GestureDetector(
                onTap: isChecking ? null : verifyProximity,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFF8458B3), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      isChecking 
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Color(0xFFA0D2EB), strokeWidth: 2))
                          : const Icon(Icons.location_on, color: Color(0xFFA0D2EB), size: 18),
                      const SizedBox(width: 12),
                      Expanded(child: Text(locationMessage, style: const TextStyle(color: Color(0xFFA0D2EB)))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    closeEnough = true;
                    locationMessage = 'GPS bypassed for demonstration.';
                  });
                },
                child: const Text('Force Bypass GPS (Demo Mode)', style: TextStyle(color: Color(0xFFA0D2EB), decoration: TextDecoration.underline)),
              ),
            ],
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: (closeEnough && total > 0 && AppData.walletBalance >= total)
                  ? () async {
                      await FirebaseFirestore.instance.collection('orders').add({
                        'status': 'Preparing',
                        'items': AppData.cart.map((i) => '${i['name']} x${i['qty']}').join(', '),
                        'total': total,
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                      setState(() {
                        AppData.walletBalance -= total;
                        AppData.cart.clear();
                      });
                      if (mounted) {
                        Navigator.pushReplacement(context, fadeRoute(OrdersScreen()));
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: closeEnough ? Colors.white : const Color(0xFFD0BDF4),
                padding: const EdgeInsets.all(14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'Pay from wallet (Rs ${formatRs(AppData.walletBalance)})',
                style: TextStyle(color: closeEnough ? Colors.black : const Color(0xFF494D5F), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}