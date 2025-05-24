import 'dart:developer';
import 'package:alpha_go/controllers/biometrics_controller.dart';
import 'package:alpha_go/controllers/user_controller.dart';
import 'package:alpha_go/controllers/wallet_controller.dart';
import 'package:alpha_go/models/const_model.dart';
import 'package:alpha_go/models/firebase_model.dart';
import 'package:alpha_go/models/user_model.dart';
import 'package:alpha_go/views/widgets/navbar_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetPasswordScreen extends StatefulWidget {
  const SetPasswordScreen(
      {super.key, this.isImport = false, this.isEnter = false});
  final bool isImport;
  final bool isEnter;

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  final WalletController controller = Get.find();
  final UserController userController = Get.find();
  final SharedPreferencesWithCache prefs = Get.find();
  final BiometricsController auth = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        if (widget.isEnter && auth.isBiometricEnabled.value) {
          final bool didAuthenticate = await auth.authenticate();
          if (didAuthenticate) {
            goToHome();
          } else {
            Get.snackbar("Error", "Authentication failed",
                colorText: Colors.white);
          }
        }
      },
    );
  }

  Future<void> goToHome() async {
    await controller.createOrRestoreWallet();

    await FirebaseUtils.users.doc(controller.address).get().then((value) async {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: "${controller.address}@alphago.com",
          password: controller.password!,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          log('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          log('Wrong password provided for that user.');
        } else {
          log(e.toString());
        }
      }
      Map<String, dynamic> data = value.data() as Map<String, dynamic>;
      userController.setUser(WalletUser(
          accountName: data["accountName"]!,
          walletAddress: data["walletAddress"]!,
          bio: data["bio"]!,
          pfpUrl: data["pfpUrl"]!,
          externalLink: data["externalLink"] ?? ""));
    });

    while (context.canPop()) {
      context.pop();
    }
    context.pushReplacement(
      '/home',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                'assets/bg.jpg',
              ),
              fit: BoxFit.cover)),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: CustomNavBar(
            leadingWidget: Padding(
              padding: EdgeInsets.all(1.w),
              child: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon:
                    const Icon(Icons.arrow_back_ios, color: Color(0xFFB4914B)),
              ),
            ),
            actionWidgets: SizedBox(
              width: 76.w,
              child: Row(
                children: [
                  Text(
                    "Set a Password",
                    style: TextStyle(
                      color: const Color(0xFFB4914B), // Gold color
                      fontSize: 18.sp,
                      fontFamily: 'Cinzel',
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.only(left: 5.w, right: 5.w, top: 5.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(widget.isEnter
                    ? "Enter your wallet's password"
                    : "Set a password to secure your wallet."),
                Padding(
                  padding: EdgeInsets.only(top: 5.h),
                  child: TextField(
                    style: Constants.inputStyle,
                    controller: password,
                    decoration: Constants.inputDecoration.copyWith(
                      hintText: "Enter your Password",
                    ),
                    cursorColor: Colors.white,
                  ),
                ),
                widget.isEnter
                    ? Padding(
                        padding: EdgeInsets.only(top: 5.h),
                        child: ElevatedButton(
                            style: Constants.buttonStyle,
                            onPressed: () async {
                              await prefs.remove('mnemonic');
                              await prefs.remove('password');
                              FirebaseAuth.instance.signOut();
                              while (context.canPop()) {
                                context.pop();
                              }
                              context.pushReplacement('/login');
                            },
                            child: const Text('Logout')),
                      )
                    : Padding(
                        padding: EdgeInsets.only(top: 5.h),
                        child: TextField(
                          cursorColor: Colors.white,
                          style: Constants.inputStyle,
                          controller: confirmPassword,
                          decoration: Constants.inputDecoration
                              .copyWith(hintText: "Confirm your password"),
                        ),
                      ),
                Padding(
                  padding: EdgeInsets.only(top: 5.h),
                  child: ElevatedButton(
                    style: Constants.buttonStyle,
                    onPressed: () async {
                      // final alphanumeric =
                      //     RegExp(r'^(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{6,}$');
                      if (password.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please enter a password"),
                            backgroundColor: Colors.red,
                          ),
                        );

                        return;
                      }
                      final alphanumeric = RegExp(
                          r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$'); // fix to above regex

                      log(alphanumeric.hasMatch(password.text).toString());
                      if (widget.isEnter) {
                        if (password.text == controller.password) {
                          goToHome();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Password does not match, please use the password you set before"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                        return;
                      } else if (password.text == confirmPassword.text) {
                        if (!alphanumeric.hasMatch(password.text)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Password must contain at least 1 uppercase letter, 1 number, and be at least 6 characters long"),
                              backgroundColor: Colors.red,
                            ),
                          );

                          return;
                        } else {
                          controller.password = password.text;
                          while (context.canPop()) {
                            context.pop();
                          }
                          context.pushReplacement('/walletCreated',
                              extra: widget.isImport);
                        }
                      }
                    },
                    child: const Text("Continue"),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
