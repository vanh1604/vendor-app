import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendor_app/controllers/order_controller.dart';
import 'package:vendor_app/provider/order_provider.dart';
import 'package:vendor_app/provider/total_earnings_provider.dart';
import 'package:vendor_app/provider/vendor_provider.dart';

class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchOrderData();
  }

  Future<void> _fetchOrderData() async {
    final user = ref.read(vendorProvider);
    if (user != null) {
      if (user.id.isEmpty) {
        return;
      }
      final OrderController orderController = OrderController();
      try {
        final res = await orderController.loadOrders(vendorId: user.id);
        ref.read(orderProvider.notifier).setOrders(res);
        ref.read(totalEarningsProvider.notifier).calculateEarnings(res);
      } catch (e) {
        print("Error fetching orders: $e");
      }
    } else {
      print("ERROR: User is null!");
    }
  }

  @override
  Widget build(BuildContext context) {
    final vendor = ref.watch(vendorProvider);
    final totalEarnings = ref.watch(totalEarningsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.purple,
              child: Text(
                vendor!.fullName[0].toUpperCase(),
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 200,
              child: Text(
                'Welcome ${vendor.fullName}',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Total Orders",
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${totalEarnings['orderCount']}',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  fontSize: 25,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Total Earnings",
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${totalEarnings['earnings'].toStringAsFixed(2)}',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
