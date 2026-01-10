import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendor_app/models/order.dart';

class TotalEarningsProvider extends StateNotifier<Map<String, dynamic>> {
  TotalEarningsProvider() : super({'earnings': 0.0, 'orderCount': 0});
  void calculateEarnings(List<Order> orders) {
    double earnings = 0.0;
    int orderCount = 0;
    for (Order order in orders) {
      if (order.delivered) {
        orderCount++;
        earnings += order.productPrice * order.quantity;
      }
    }
    state = {'earnings': earnings, 'orderCount': orderCount};
  }
}

final totalEarningsProvider =
    StateNotifierProvider<TotalEarningsProvider, Map<String, dynamic>>(
      (ref) => TotalEarningsProvider(),
    );
