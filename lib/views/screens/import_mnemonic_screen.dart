import 'dart:developer';

import 'package:alpha_go/controllers/wallet_controller.dart';
import 'package:alpha_go/views/screens/set_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enter your Seed Phrase"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text(
              "Enter your wallet's private Seed Phrase with Spaces between each phrase. This is the unique key to your wallet."),
          TextFormField(
              controller: mnemonic,
              keyboardType: TextInputType.multiline,
              maxLines: 5,
              decoration:
                  const InputDecoration(hintText: "Enter your mnemonic")),
          ElevatedButton(
              onPressed: () {
                log(mnemonic.text);
                controller.mnemonic = mnemonic.text;
                Get.to(() => const SetPasswordScreen(
                      isImport: true,
                    ));
              },
              child: const Text("Continue")),
        ],
      ),
    );
  }
}
