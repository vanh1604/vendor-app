import 'package:flutter_riverpod/legacy.dart';
import 'package:vendor_app/models/vendor.dart';

class VendorProvider extends StateNotifier<Vendor?> {
  VendorProvider() : super(null);
  Vendor? get getVendor => state;
  void setVendor(String vendor) {
    state = Vendor.fromJson(vendor);
    print("State updated: $state");
  }

  void signOut() {
    state = null;
  }
}

final vendorProvider = StateNotifierProvider<VendorProvider, Vendor?>((ref) {
  return VendorProvider();
});
