import 'dart:developer';

import 'package:alpha_go/controllers/wallet_controller.dart';
import 'package:alpha_go/models/const_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class EnterWalletMnemonic extends StatefulWidget {
  const EnterWalletMnemonic({super.key});

  @override
  State<EnterWalletMnemonic> createState() => _EnterWalletMnemonicState();
}

class _EnterWalletMnemonicState extends State<EnterWalletMnemonic> {
  TextEditingController mnemonic = TextEditingController();
  final WalletController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/bg.jpg"), fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(1.h),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xffb4914b),
                ),
                height: 0.2.h,
              )),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: const Text("Enter your Seed Phrase",
              style: TextStyle(color: Colors.white)),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                  "Enter your wallet's private Seed Phrase with Spaces between each phrase. This is the unique key to your wallet."),
              Padding(
                padding: EdgeInsets.only(top: 5.h, bottom: 5.h),
                child: TextFormField(
                  style: const TextStyle(
                      color: Colors.white, fontFamily: 'Roboto'),
                  controller: mnemonic,
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  decoration: Constants.inputDecoration.copyWith(
                    hintText: "Enter your Mnemonic Seed Phrase",
                  ),
                  cursorColor: Colors.white,
                ),
              ),
              SizedBox(
                width: 50.w,
                height: 7.h,
                child: ElevatedButton(
                    onPressed: () {
                      final mnemonicRegex =
                          RegExp(r'^(?:[a-zA-Z]+(?:\s|$)){12}$');
                      log(mnemonicRegex.hasMatch(mnemonic.text).toString());
                      if (!mnemonicRegex.hasMatch(mnemonic.text)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Please enter a valid Seed Phrase",
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      controller.mnemonic = mnemonic.text;
                      context.go('/setPassword', extra: [false, true]);
                    },
                    style: Constants.buttonStyle,
                    child: Text(
                      "Continue",
                      style: TextStyle(color: Colors.white, fontSize: 20.sp),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
