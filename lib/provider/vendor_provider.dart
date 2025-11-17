import 'package:flutter_riverpod/legacy.dart';
import 'package:vendor_app/models/vendor.dart';

class VendorProvider extends StateNotifier<Vendor?> {
  VendorProvider()
    : super(
        Vendor(
          id: '',
          fullName: '',
          state: '',
          city: '',
          locality: '',
          email: '',
          password: '',
          role: '',
          token: '',
        ),
      );
  Vendor? get getVendor => state;
  void setVendor(String vendor) {
    state = Vendor.fromJson(vendor);
  }

  void signOut() {
    state = null;
  }
}

final vendorProvider = StateNotifierProvider<VendorProvider, Vendor?>((ref) {
  return VendorProvider();
});
