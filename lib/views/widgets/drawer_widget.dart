
import 'package:alpha_go/controllers/biometrics_controller.dart';
import 'package:alpha_go/controllers/user_controller.dart';

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find();
    final SharedPreferencesWithCache prefs = Get.find();
    final BiometricsController auth = Get.find();

    return Drawer(
      shadowColor: const Color(0xffb4914b),
      surfaceTintColor: const Color.fromARGB(255, 52, 52, 52),
      elevation: 10.w,
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 3.w, top: 10.h, bottom: 8.h),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xffb4914b),
                  radius: 9.w,
                  child: CircleAvatar(
                    radius: 8.w,
                    backgroundImage: CachedNetworkImageProvider(
                      userController.user.pfpUrl,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userController.user.accountName,
                      style: TextStyle(
                        color: const Color(0xffb4914b),
                        fontSize: 21.px,
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 34.w,
                          child: Text(
                            userController.user.walletAddress,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xffb4914b),
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(
                                text: userController.user.walletAddress));

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Username copied!")),
                            );
                          },
                          child: Icon(Icons.copy,
                              size: 18.sp, color: const Color(0xffb4914b)),
                        ),
                        SizedBox(width: 1.w),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          InkWell(
            onTap: () {
              while (context.canPop()) {
                context.pop();
              }
              context.pushReplacement('/home');
            },
            child: ListTile(
              leading:
                  Icon(Icons.home, color: const Color(0xffb4914b), size: 24.px),
              title: Text(
                'Home',
                style: TextStyle(
                  color: const Color(0xffb4914b),
                  fontSize: 24.px,
                ),
              ),
            ),
          ),
          SizedBox(height: 1.h),
          InkWell(
            onTap: () {
              context.push('/marketplace');
            },
            child: ListTile(
              leading: Icon(Icons.store,
                  color: const Color(0xffb4914b), size: 24.px),
              title: Text(
                'MarketPlace',
                style: TextStyle(
                  color: const Color(0xffb4914b),
                  fontSize: 24.px,
                ),
              ),
            ),
          ),
          SizedBox(height: 1.h),
          InkWell(
            onTap: () {
              context.push('/eventDetails');
              
           
            },
            child: ListTile(
              leading: Icon(Icons.settings,
                  color: const Color(0xffb4914b), size: 24.px),
              title: Text(
                'Events',
                style: TextStyle(
                  color: const Color(0xffb4914b),
                  fontSize: 24.px,
                ),
              ),
            ),
          ),
          SizedBox(height: 1.h),
          
          // InkWell(
          //   onTap: () {
          //     Navigator.pop(context);
          //   },
          //   child: ListTile(
          //     leading: Icon(Icons.event,
          //         color: const Color(0xffb4914b), size: 24.px),
          //     title: Text(
          //       'Events',
          //       style: TextStyle(
          //         color: const Color(0xffb4914b),
          //         fontSize: 24.px,
          //       ),
          //     ),
          //   ),
          // ),
          // SizedBox(height: 1.h),
          // InkWell(
          //   onTap: () {
          //     Navigator.pop(context);
          //   },
          //   child: ListTile(
          //     leading: Icon(Icons.settings,
          //         color: const Color(0xffb4914b), size: 24.px),
          //     title: Text(
          //       'Settings',
          //       style: TextStyle(
          //         color: const Color(0xffb4914b),
          //         fontSize: 24.px,
          //       ),
          //     ),
          //   ),
          // ),
          SizedBox(height: 1.h),
          auth.canCheckBiometrics
              ? Obx(
                  () => ListTile(
                    contentPadding: EdgeInsets.only(right: 7.w, left: 16),
                    leading: Icon(Icons.fingerprint,
                        color: const Color(0xffb4914b), size: 24.px),
                        
                    title: Padding(
                      padding:  EdgeInsets.only(right: 32.w),
                      child: AnimatedToggleSwitch<bool>.dual(
                        current: auth.isBiometricEnabled.value,
                        first: false,
                        second: true,
                        height: 3.2.h,
                        fittingMode: FittingMode.preventHorizontalOverlapping,
                        onChanged: (bool value) => auth.toggleBiometric(value),
                         styleBuilder: (value) => ToggleStyle(
                          backgroundColor: value
                              ? Colors.green
                              : Colors.red, // active/inactive color
                          indicatorColor: Colors.white,
                        ),
                        iconBuilder: (value) => Icon(
                          value ? Icons.lock_open : Icons.lock_outline,
                          color: value ? Colors.white : Colors.black,
                        ),
                        textBuilder: (value) => Text(
                          value ? "ON" : "OFF",
                          style: TextStyle(
                            color: value ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox(),
          SizedBox(height: 6.h),
          // InkWell(
          //   onTap: () {
          //     Navigator.pop(context);
          //   },
          //   child: ListTile(
          //     leading: Icon(Icons.contacts,
          //         color: const Color(0xffb4914b), size: 24.px),
          //     title: Text(
          //       'Contact Us',
          //       style: TextStyle(
          //         color: const Color(0xffb4914b),
          //         fontSize: 24.px,
          //       ),
          //     ),
          //   ),
          // ),
          // SizedBox(height: 1.h),
          InkWell(
            onTap: () async {
              await prefs.remove('mnemonic');
              await prefs.remove('password');
              FirebaseAuth.instance.signOut();

              while (context.canPop()) {
                context.pop();
              }
              context.pushReplacement('/login');
            },
            child: ListTile(
              leading: Icon(Icons.logout,
                  color: const Color(0xffb4914b), size: 24.px),
              title: Text(
                'Logout',
                style: TextStyle(
                  color: const Color(0xffb4914b),
                  fontSize: 24.px,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
