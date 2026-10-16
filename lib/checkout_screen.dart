import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
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
  String locationMessage = 'Tap to verify GPS proximity (< 800m)';

  final double targetLat = 10.904157;
  final double targetLng = 76.898561;

  Future<void> verifyProximity() async {
    setState(() {
      isChecking = true;
      locationMessage = 'Acquiring satellite lock...';
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
    double distance = Geolocator.distanceBetween(position.latitude, position.longitude, targetLat, targetLng);

    setState(() {
      isChecking = false;
      if (distance <= 800) {
        closeEnough = true;
        locationMessage = 'Campus Proximity Verified (${distance.toStringAsFixed(0)}m)';
      } else {
        locationMessage = 'Too far! You are ${distance.toStringAsFixed(0)}m away.';
      }
    });
  }

  void _showQrPaymentDialog(double total) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF494D5F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Scan QR to Pay (UPI)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Scan with GPay / PhonePe / Paytm', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: QrImageView(
                data: 'upi://pay?pa=amritacanteen@upi&pn=CampusCanteen&am=$total&cu=INR',
                version: QrVersions.auto,
                size: 180.0,
              ),
            ),
            const SizedBox(height: 14),
            Text('Amount: Rs ${formatRs(total)}', style: const TextStyle(color: Color(0xFFA0D2EB), fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () {
              Navigator.pop(context);
              _processOrder(total, paymentMethod: 'UPI QR Code');
            },
            child: const Text('Simulate Payment Success', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _generateAndPrintPdf(String orderId, double total) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('CAMPUS CANTEEN INVOICE', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text('Order ID: #$orderId'),
            pw.Text('Date: ${DateTime.now().toString().substring(0, 16)}'),
            pw.Divider(),
            pw.SizedBox(height: 10),
            ...AppData.cart.map((item) => pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('${item['name']} x${item['qty']}'),
                    pw.Text('Rs ${formatRs(item['price'] * item['qty'])}'),
                  ],
                )),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total Paid', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Rs ${formatRs(total)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'canteen_invoice_$orderId.pdf');
  }

  Future<void> _processOrder(double total, {required String paymentMethod}) async {
    String orderId = DateTime.now().millisecondsSinceEpoch.toString().substring(5);

    await FirebaseFirestore.instance.collection('orders').doc(orderId).set({
      'status': 'Preparing',
      'items': AppData.cart.map((i) => '${i['name']} x${i['qty']}').join(', '),
      'total': total,
      'paymentMethod': paymentMethod,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Generate PDF Bill automatically on success
    await _generateAndPrintPdf(orderId, total);

    setState(() {
      if (paymentMethod == 'Wallet') AppData.walletBalance -= total;
      AppData.cart.clear();
    });

    if (mounted) {
      Navigator.pushReplacement(context, fadeRoute(OrdersScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    double total = AppData.cartTotal();

    return Scaffold(
      backgroundColor: const Color(0xFF494D5F),
      appBar: AppBar(
        title: const Text('Secure Checkout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF494D5F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                children: [
                  const Text('Order Summary', style: TextStyle(color: Color(0xFFA0D2EB), fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ...AppData.cart.map((item) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFF8458B3).withOpacity(0.4), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text('${item['name']} x${item['qty']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                            Text('Rs ${formatRs(item['price'] * item['qty'])}', style: const TextStyle(color: Colors.white70)),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                              onPressed: () => setState(() => AppData.removeFromCart(item['name'])),
                            )
                          ],
                        ),
                      )),
                  const Divider(color: Color(0xFFD0BDF4), height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Rs ${formatRs(total)}', style: const TextStyle(color: Color(0xFFA0D2EB), fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Text('Proximity Verification', style: TextStyle(color: Color(0xFFA0D2EB), fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: isChecking ? null : verifyProximity,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: closeEnough ? Colors.green.withOpacity(0.2) : const Color(0xFF8458B3),
                        border: Border.all(color: closeEnough ? Colors.greenAccent : const Color(0xFFD0BDF4)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          isChecking
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Color(0xFFA0D2EB), strokeWidth: 2))
                              : Icon(closeEnough ? Icons.check_circle_rounded : Icons.location_on_rounded, color: closeEnough ? Colors.greenAccent : const Color(0xFFA0D2EB)),
                          const SizedBox(width: 12),
                          Expanded(child: Text(locationMessage, style: TextStyle(color: closeEnough ? Colors.greenAccent : const Color(0xFFA0D2EB), fontWeight: FontWeight.w600))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => setState(() {
                        closeEnough = true;
                        locationMessage = 'GPS bypassed for demonstration.';
                      }),
                      child: const Text('Force Bypass GPS (Demo Mode)', style: TextStyle(color: Colors.amberAccent, decoration: TextDecoration.underline)),
                    ),
                  ),
                ],
              ),
            ),
            if (closeEnough && total > 0) ...[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF494D5F)),
                onPressed: AppData.walletBalance >= total ? () => _processOrder(total, paymentMethod: 'Wallet') : null,
                label: Text('Pay via Wallet (Bal: Rs ${formatRs(AppData.walletBalance)})', style: const TextStyle(color: Color(0xFF494D5F), fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA0D2EB),
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF494D5F)),
                onPressed: () => _showQrPaymentDialog(total),
                label: const Text('Scan QR Code (UPI Payment)', style: TextStyle(color: Color(0xFF494D5F), fontWeight: FontWeight.bold)),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)),
                child: const Text('Verify GPS Proximity to Unlock Payments', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
              ),
            ]
          ],
        ),
      ),
    );
  }
}