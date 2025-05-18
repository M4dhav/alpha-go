import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkRowWidget extends StatelessWidget {
  final String label;
  final String? url;

  const LinkRowWidget({super.key, required this.label, required this.url});

  void _launchURL(String? url) {
    if (url != null && url.isNotEmpty) {
      launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: GestureDetector(
        onTap: () => _launchURL(url),
        child: Text(
          "$label: $url",
          style: TextStyle(
            fontSize: 15.sp,
            color: const Color(0xFFB4914B),
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
