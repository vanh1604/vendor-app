import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vendor_app/global_variables.dart';
import 'package:vendor_app/models/order.dart';
import 'package:vendor_app/services/manage_http_response.dart';

class OrderController {
  Future<List<Order>> loadOrders({required String vendorId}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth-token');
      final url = "$uri/api/orders/vendors/$vendorId";
      http.Response res = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
          "Authorization": "Bearer $token",
        },
      );

      if (res.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(res.body);

        final List<dynamic> data = responseData['orders'];

        List<Order> orders = data.map((order) => Order.fromMap(order)).toList();
        return orders;
      } else {
        throw Exception(
          "Failed to load orders - Status: ${res.statusCode}, Body: ${res.body}",
        );
      }
    } catch (e) {
      print("ERROR in loadOrders: $e");
      throw Exception('An error occurred while loading orders: $e');
    }
  }

  Future<void> deleteOrder({required String orderId, required context}) async {
    try {
      http.Response res = await http.delete(
        Uri.parse("$uri/api/orders/$orderId"),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
        },
      );
      manageHttpResponse(
        res: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, "Order deleted successfully");
        },
      );
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> updateDeliveryStatus({
    required String orderId,
    required context,
  }) async {
    try {
      http.Response res = await http.patch(
        Uri.parse("$uri/api/orders/$orderId/delivered"),
        body: jsonEncode({'delivered': true}),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
        },
      );
      manageHttpResponse(
        res: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, "Order status updated successfully");
        },
      );
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> updateProccessStatus({
    required String orderId,
    required context,
  }) async {
    try {
      http.Response res = await http.patch(
        Uri.parse("$uri/api/orders/$orderId/processing"),
        body: jsonEncode({'processing': false}),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
        },
      );
      manageHttpResponse(
        res: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, "Order status updated successfully");
        },
      );
    } catch (e) {
      print("Error: $e");
    }
  }
}
