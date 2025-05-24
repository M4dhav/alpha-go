import 'dart:developer';

import 'package:alpha_go/controllers/mint_ordinal_controller.dart';
import 'package:alpha_go/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class MintOrdinalsScreen extends StatefulWidget {
  const MintOrdinalsScreen({super.key});

  @override
  State<MintOrdinalsScreen> createState() => _MintOrdinalsScreenState();
}

class _MintOrdinalsScreenState extends State<MintOrdinalsScreen> {
  MintOrdinalController inscriptionController = MintOrdinalController();
  final WalletController walletController = Get.find();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/bg.jpg"), fit: BoxFit.cover)),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Column(
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        Map<String, dynamic> inscriptionData =
                            await inscriptionController.pickPictureAndEncode();
                        if (inscriptionData['success'] == true) {
                          await inscriptionController.inscribe(
                              inscriptionData, walletController.address!, 2);
                          if (inscriptionController.inscriptionModel != null) {
                            await inscriptionController.fetchOrderDetails(
                                inscriptionController.inscriptionModel!.id);
                          }
                          setState(() {});
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(inscriptionData['message']),
                            ),
                          );
                        }
                      },
                      child: const Text('Select File')),
                  SizedBox(
                      height: 100,
                      width: 100,
                      child: Image.network(
                        inscriptionController
                                .inscriptionModel?.inscriptionURL ??
                            "",
                        fit: BoxFit.contain,
                      )),
                  Text(
                      'Inscription ID: ${inscriptionController.inscriptionModel?.id ?? ""}'),
                  Text(
                      "Inscription Cost: ${inscriptionController.inscriptionModel?.totalFee ?? ""}"),
                  Text(
                      'Inscription Status: ${inscriptionController.inscriptionModel?.status ?? ""}'),
                  Text(
                      'Payment Address: ${inscriptionController.inscriptionModel?.paymentAddress ?? ""}'),
                  IconButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(
                            text: inscriptionController
                                    .inscriptionModel?.paymentAddress ??
                                ""));

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Payment address copied!")),
                        );
                      },
                      icon: const Icon(Icons.copy)),
                  ElevatedButton(
                      onPressed: () {
                        log(inscriptionController.inscriptionModel!.id);
                        walletController.sendSats(
                            inscriptionController
                                .inscriptionModel!.paymentAddress!,
                            inscriptionController.inscriptionModel!.totalFee);
                      },
                      child: const Text('Send Payment'))
                ],
              ),
            ),
          )),
    );
  }
}
