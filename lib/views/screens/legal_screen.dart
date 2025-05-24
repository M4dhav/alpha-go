import 'dart:developer';

import 'package:alpha_go/models/const_model.dart';
import 'package:alpha_go/views/widgets/navbar_widget.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalPage extends StatefulWidget {
  const LegalPage({super.key, required this.isGenerate});
  final bool isGenerate;

  @override
  State<LegalPage> createState() => LegalPageState();
}

class LegalPageState extends State<LegalPage> {
  bool isAuthorized = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/bg.jpg"), fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomNavBar(
          leadingWidget: Padding(
            padding: EdgeInsets.all(1.w),
            child: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFB4914B)),
            ),
          ),
          actionWidgets: SizedBox(
            width: 75.w,
            child: Row(
              children: [
                Text(
                  "Legal",
                  style: TextStyle(
                    color: const Color(0xFFB4914B), // Gold color
                    fontSize: 20.sp,
                    fontFamily: 'Cinzel',
                  ),
                ),
                const Spacer()
              ],
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 5.h, right: 5.w, left: 5.w),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: const Text(
                      "Please review the Alpha Protocol Wallet Privacy Policy and Terms of Services,"),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Terms of Service"),
                    IconButton(
                      color: Colors.white,
                      icon: const Icon(Icons.link),
                      onPressed: () async {
                        final Uri url =
                            Uri.parse('https://alphaprotocol.network');
                        await launchUrl(url);
                      },
                    ),
                  ],
                ),
                const Divider(
                  thickness: 2,
                  color: Color(0xffb4914b),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Privacy Policy"),
                    IconButton(
                      color: Colors.white,
                      icon: const Icon(Icons.link),
                      onPressed: () async {
                        final Uri url =
                            Uri.parse('https://alphaprotocol.network');
                        await launchUrl(url);
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: const Text(
                      "We would like to collect anonymous usage data to better understand users and improve the app. You can change this setting at any time."),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Authorize Data Collection"),
                      SizedBox(
                        height: 4.h,
                        width: 20.w,
                        child: AnimatedToggleSwitch<bool>.dual(
                          current: isAuthorized,
                          first: false,
                          second: true,
                          fittingMode: FittingMode.preventHorizontalOverlapping,
                          onChanged: (bool value) => setState(() {
                            log(value.toString());
                            isAuthorized = value;
                          }),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 4.h),
                  width: 50.w,
                  height: 10.h,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push(
                        widget.isGenerate
                            ? '/generateMnemonic'
                            : '/enterMnemonic',
                      );
                    },
                    style: Constants.buttonStyle,
                    child: Text(
                      "Accept",
                      style: TextStyle(
                          fontFamily: 'Cinzel',
                          color: Colors.white,
                          fontSize: 20.sp),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
