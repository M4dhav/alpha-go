import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CardNFT extends StatelessWidget {
  final String nftName;
  final String creator;
  final String imageUrl;
  final String description;

  const CardNFT({
    super.key,
    required this.nftName,
    required this.creator,
    required this.imageUrl,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xffb4914b), // Golden color
          width: 2, // Border thickness
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: 26.h, // Adjust the height as needed
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding:  EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nftName,
                  style:  TextStyle(
                    fontSize: 20.px,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xffb4914b),
                  ),
                ),
                 SizedBox(height: 1.h),
                Text(
                  'Creator: $creator',
                  style:  TextStyle(
                    fontSize: 16.px,
                    color: Colors.white70,
                  ),
                ),
                 SizedBox(height: 1.h),
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style:  TextStyle(
                    fontSize: 14.px,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
