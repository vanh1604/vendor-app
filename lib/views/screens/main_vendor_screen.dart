import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vendor_app/views/screens/nav_screens/earnings_screen.dart';
import 'package:vendor_app/views/screens/nav_screens/edit_screen.dart';
import 'package:vendor_app/views/screens/nav_screens/orders_screen.dart';
import 'package:vendor_app/views/screens/nav_screens/profile_screen.dart';
import 'package:vendor_app/views/screens/nav_screens/upload_screen.dart';

class MainVendorScreen extends StatefulWidget {
  MainVendorScreen({super.key});

  @override
  _MainVendorScreenState createState() => _MainVendorScreenState();
}

class _MainVendorScreenState extends State<MainVendorScreen> {
  int _pageIndex = 0;
  List<Widget> pages = [
    EarningsScreen(),
    UploadScreen(),
    EditScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          setState(() {
            _pageIndex = value;
          });
        },
        currentIndex: _pageIndex,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.purple,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.money_dollar),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.upload_circle),
            label: 'Upload',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Edit'),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.shopping_cart),
            label: 'Orders',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      body: pages[_pageIndex],
    );
  }
}
