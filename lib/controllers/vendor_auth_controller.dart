import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vendor_app/global_variables.dart';
import 'package:vendor_app/models/vendor.dart';
import 'package:http/http.dart' as http;
import 'package:vendor_app/provider/vendor_provider.dart';
import 'package:vendor_app/services/manage_http_response.dart';
import 'package:vendor_app/views/screens/main_vendor_screen.dart';

final providerContainer = ProviderContainer();

class VendorAuthController {
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
    required String storeName,
    required String storeImage,
    required String storeDescription,
    required context,
    VoidCallback? onSuccess,
  }) async {
    try {
      Vendor vendor = Vendor(
        id: '',
        state: '',
        city: '',
        locality: '',
        role: '',
        token: '',
        fullName: fullName,
        email: email,
        password: password,
        storeName: storeName,
        storeImage: storeImage,
        storeDescription: storeDescription,
      );
      final response = await http.post(
        Uri.parse('$uri/api/vendor/signup'),
        body: vendor.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      manageHttpResponse(
        res: response,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Vendor signed up successfully');
          if (onSuccess != null) {
            onSuccess();
          }
        },
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
    required context,
    required WidgetRef ref,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$uri/api/vendor/signin'),
        body: jsonEncode({'email': email, 'password': password}),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      manageHttpResponse(
        res: response,
        context: context,
        onSuccess: () async {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          final responseData = jsonDecode(response.body);
          String token = responseData['token'];
          final user = responseData['user'];
          await preferences.setString('auth-token', token);
          final vendorJson = jsonEncode(user);
          //providerContainer.read(vendorProvider.notifier).setVendor(vendorJson);
          ref.read(vendorProvider.notifier).setVendor(vendorJson);
          await preferences.setString('vendor', vendorJson);
          showSnackBar(context, 'Vendor signed in successfully');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainVendorScreen()),
            (route) => false,
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }
}
