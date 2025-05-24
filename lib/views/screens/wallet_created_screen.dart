import 'dart:developer';
import 'package:alpha_go/models/const_model.dart';
import 'package:alpha_go/controllers/wallet_controller.dart';
import 'package:alpha_go/views/widgets/navbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WalletCreatedScreen extends StatefulWidget {
  const WalletCreatedScreen({super.key, required this.isImport});
  final bool isImport;
  @override
  State<WalletCreatedScreen> createState() => _WalletCreatedScreenState();
}

class _WalletCreatedScreenState extends State<WalletCreatedScreen> {
  bool isLoading = false;
  TextEditingController address = TextEditingController();
  TextEditingController balance = TextEditingController();
  final WalletController controller = Get.find();
  final SharedPreferencesWithCache prefs = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.createOrRestoreOrdinalWallet().then((value) {
        setState(() {
          address.text = controller.ordinalAddress!;
        });
      });
      await controller.createOrRestoreFundingWallet();

      try {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: "${controller.ordinalAddress!}@alphago.com",
          password: controller.password!,
        )
            .then((value) async {
          log("User has been Logged in");
        });
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          log('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          log('The account already exists for that email.');
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: "${controller.ordinalAddress}@alphago.com",
            password: controller.password!,
          );
        }
      } catch (e) {
        log("An error has occured ${e.toString()}");
      }
      await prefs.setString("mnemonic", controller.mnemonic!);
      await prefs.setString("password", controller.password!);
      await controller.syncWallet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/bg.jpg'), fit: BoxFit.cover)),
        child: Scaffold(
          appBar: CustomNavBar(
            leadingWidget: const SizedBox(),
            actionWidgets: SizedBox(
              width: 76.w,
              child: Row(
                children: [
                  Text(
                    "Wallet Created!",
                    style: TextStyle(
                      color: const Color(0xFFB4914B), // Gold color
                      fontSize: 20.sp,
                      fontFamily: 'Cinzel',
                    ),
                  ),
                ],
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Center(
                          child: Text(
                        "Congratulations your wallet is ${widget.isImport ? "imported" : "created"}",
                        textAlign: TextAlign.center,
                      )),
                      Padding(
                        padding: EdgeInsets.only(top: 5.h),
                        child: TextFormField(
                            readOnly: true,
                            controller: address,
                            style: Constants.inputStyle,
                            maxLines: 2,
                            decoration: Constants.inputDecoration.copyWith(
                                hintText: "Your Wallet Address",
                                suffixIconColor: const Color(0xffb4914b),
                                suffixIcon: IconButton(
                                    onPressed: () async {
                                      if (controller.ordinalAddress != null) {
                                        await Clipboard.setData(ClipboardData(
                                                text:
                                                    controller.ordinalAddress!))
                                            .then((onCallback) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Wallet Address Copied!',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              backgroundColor:
                                                  Color(0xffb4914b),
                                            ),
                                          );
                                        });
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.copy,
                                    )))),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5.h),
                        child: TextFormField(
                            controller: balance,
                            style: Constants.inputStyle,
                            readOnly: true,
                            keyboardType: TextInputType.multiline,
                            maxLines: 2,
                            decoration: Constants.inputDecoration.copyWith(
                              hintText:
                                  "Please refresh to fetch wallet balance",
                            )),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5.h),
                        child: ElevatedButton(
                          style: Constants.buttonStyle,
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });
                            await controller.syncWallet();
                            await controller
                                .getOrdinalWalletBalance()
                                .then((value) {
                              balance.text =
                                  "${controller.ordinalWalletBalance.toString()} Sats";
                            });
                            setState(() {
                              isLoading = false;
                            });
                            log("Refreshed");
                          },
                          child: const Text("Refresh"),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5.h),
                        child: ElevatedButton(
                          style: Constants.buttonStyle,
                          onPressed: () {
                            if (FirebaseAuth.instance.currentUser != null) {
                              context.pushReplacement('/onboarding');
                            }
                          },
                          child: const Text("Continue"),
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
