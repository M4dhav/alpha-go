import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SearchResultTile extends StatelessWidget {
  final String title;
  const SearchResultTile({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 1.3.h, horizontal: 2.w),
        padding: EdgeInsets.symmetric(vertical: 1.8.h, horizontal: 1.5.w),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xffb4914b),
            width: 0.3,
          ),
        ),
        child: ListTile(
          leading: CircleAvatar(
            radius: 5.7.w,
            backgroundColor: const Color(0xffb4914b),
            child: CircleAvatar(
              backgroundImage: const AssetImage('assets/profile.jpg'),
              radius: 5.w,
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
              ),
              Text(
                overflow: TextOverflow.clip,
                'randm description here ...',
                style: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
            ],
          ),
          trailing: const Icon(Icons.more_vert, color: Color(0xffb4914b)),
        ),
      ),
    );
  }
}
