import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vendor_app/global_variables.dart';
import 'package:vendor_app/models/product.dart';
import 'package:vendor_app/services/manage_http_response.dart';

class ProductController {
  Future<void> uploadProduct({
    required String name,
    required String description,
    required double price,
    required int quantity,
    required String category,
    required String subCategory,
    required List<File> pickedImages,
    required String vendorId,
    required String fullName,
    required BuildContext context,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth-token');
    if (pickedImages.isNotEmpty) {
      final cloudinary = CloudinaryPublic("duzytwoln", "dmwyjltu");
      List<String> images = [];
      for (var i = 0; i < pickedImages.length; i++) {
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(pickedImages[i].path, folder: name),
        );
        images.add(response.secureUrl);
      }
      print(images);
      if (category.isNotEmpty && subCategory.isNotEmpty) {
        final Product product = Product(
          id: '',
          name: name,
          description: description,
          price: price,
          quantity: quantity,
          category: category,
          subCategory: subCategory,
          images: images,
          vendorId: vendorId,
          fullName: fullName,
        );
        http.Response res = await http.post(
          Uri.parse("$uri/api/createproduct"),
          body: product.toJson(),
          headers: <String, String>{
            "Content-Type": "application/json; charset=UTF-8",
            "Authorization": "Bearer $token",
          },
        );
        manageHttpResponse(
          res: res,
          context: context,
          onSuccess: () {
            showSnackBar(context, "Product uploaded successfully");
          },
        );
      } else {
        showSnackBar(context, "Please select category and subcategory");
      }
    } else {
      showSnackBar(context, "Please select at least one image");
    }
  }
}
