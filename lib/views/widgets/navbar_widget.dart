import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CustomNavBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget leadingWidget;
  final Widget actionWidgets;

  const CustomNavBar({
    super.key,
    required this.leadingWidget,
    required this.actionWidgets,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20), // Only bottom-left is rounded
          bottomRight: Radius.circular(20), // Only bottom-right is rounded
        ),

        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.shade300,
        //     blurRadius: 5,
        //     offset: const Offset(0, 3),
        //   ),
        // ],

        border: Border(
          bottom:
              BorderSide(color: Color(0xffb4914b), width: 2), // Bottom border
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding:  EdgeInsets.symmetric(
              horizontal: 4.w, vertical: 13), // Increased vertical padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              leadingWidget,
              // Row(
              //   children: [
              //     Text(
              //       username,
              //       style: const TextStyle(
              //         fontSize: 18,
              //         fontWeight: FontWeight.bold,
              //         color: Color(0xffb4914b),
              //       ),
              //     ),
              //     const SizedBox(width: 8),
              //     GestureDetector(
              //       onTap: () {
              //         Clipboard.setData(ClipboardData(text: username));
              //         onCopyPressed();
              //         ScaffoldMessenger.of(context).showSnackBar(
              //           const SnackBar(content: Text("Username copied!")),
              //         );
              //       },
              //       child: const Icon(Icons.copy,
              //           size: 18, color: Color(0xffb4914b)),
              //     ),
              //   ],
              // ),

              // Grouped icons for Add and Menu
              // Row(
              //   children: [
              //     IconButton(
              //       icon: const Icon(Icons.add_box,
              //           size: 26, color: Color(0xffb4914b)),
              //       onPressed: onAddPressed,
              //     ),
              //     IconButton(
              //       icon: const Icon(Icons.menu,
              //           size: 29, color: Color(0xffb4914b)),
              //       onPressed: onMenuPressed,
              //     ),
              //   ],
              // ),
              actionWidgets,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize =>  Size.fromHeight(10.h); // Increased height
}
