import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerPlaceholderWidget extends StatelessWidget {
  const ShimmerPlaceholderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[700]!,
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: List.generate(3, (index) {
            return Container(
              margin: EdgeInsets.symmetric(vertical: 1.h),
              height: 150,
              color: Colors.white,
            );
          }),
        ),
      ),
    );
  }
}
