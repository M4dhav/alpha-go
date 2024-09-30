import 'dart:developer';
import 'package:alpha_go/views/screens/onboarding.dart';
import 'package:alpha_go/controllers/wallet_controller.dart';
import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  final SharedPreferences prefs = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller
          .createOrRestoreWallet(
        Network.testnet,
      )
          .then((value) {
        setState(() {
          address.text = controller.address!;
        });
      });

      try {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: "${controller.address!}@alphago.com",
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
            email: "${controller.address}@alphago.com",
            password: controller.password!,
          );
        }
      } catch (e) {
        log("An error has occured ${e.toString()}");
      }

      await controller.syncWallet();
      await prefs.setString("mnemonic", controller.mnemonic!);
      await prefs.setString("password", controller.password!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Scaffold(
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Center(
                      child: Text(
                          "Congratulations your wallet is ${widget.isImport ? "imported" : "created"}")),
                  TextFormField(
                      readOnly: true,
                      controller: address,
                      maxLines: 5,
                      decoration: const InputDecoration(
                          hintText: "Wallet Address Loading")),
                  Center(
                    child: TextFormField(
                        controller: balance,
                        readOnly: true,
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        decoration: const InputDecoration(
                            hintText:
                                "Please Refresh to fetch wallet balance")),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      await controller.syncWallet();
                      await controller.getBalance().then((value) {
                        balance.text = "${controller.balance.toString()} Sats";
                      });
                      setState(() {
                        isLoading = false;
                      });
                      log("Refreshed");
                    },
                    child: const Text("Refresh"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (FirebaseAuth.instance.currentUser != null) {
                        Get.off(const OnboardingScreen());
                      }

                      // Get.to(() => const NavBar());
                    },
                    child: const Text("Continue"),
                  ),
                ],
              ),
      ),
    );
  }
}
