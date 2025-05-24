import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SearchBarWidget extends StatelessWidget {
  final Function(String) onSearch;

  const SearchBarWidget({super.key, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onSearch,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.6),
        hintText: 'Search...',
        hintStyle: TextStyle(color: Colors.grey, fontSize: 16.sp),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.sp),
          borderSide: BorderSide(color: const Color(0xffb4914b), width: 1.w),
        ),
      ),
      style: TextStyle(color: Colors.white, fontSize: 18.sp),
    );
  }
}
