import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vendor_app/global_variables.dart';
import 'package:vendor_app/models/order.dart';
import 'package:vendor_app/services/manage_http_response.dart';

class OrderController {
  Future<List<Order>> loadOrders({required String vendorId}) async {
    try {
      print("=== DEBUG OrderController.loadOrders ===");
      print("VendorId received: '$vendorId'");
      print("VendorId length: ${vendorId.length}");
      print("VendorId isEmpty: ${vendorId.isEmpty}");

      final url = "$uri/api/orders/vendors/$vendorId";
      print("Full API URL: $url");

      http.Response res = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
        },
      );

      print("API Response status code: ${res.statusCode}");
      print("API Response body: ${res.body}");

      if (res.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(res.body);
        print("Parsed response data: $responseData");
        final List<dynamic> data = responseData['orders'];
        print("Orders count: ${data.length}");
        List<Order> orders = data.map((order) => Order.fromMap(order)).toList();
        return orders;
      } else {
        print("ERROR: Failed to load orders - Status: ${res.statusCode}");
        throw Exception("Failed to load orders - Status: ${res.statusCode}, Body: ${res.body}");
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
}
