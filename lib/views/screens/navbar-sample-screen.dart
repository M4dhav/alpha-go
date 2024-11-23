import 'package:alpha_go/views/widgets/navbar_widget.dart';
import 'package:flutter/material.dart';

class NavbarSample extends StatelessWidget {
  const NavbarSample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomNavBar(
        username: "@TB1QT5JWMV83D...",
        onAddPressed: () {
          print("Add Pressed");
        },
        onMenuPressed: () {
          print("Menu Pressed");
        },
        onCopyPressed: () {
          print("Copy Pressed");
        },
      ),
    );
  }
}
