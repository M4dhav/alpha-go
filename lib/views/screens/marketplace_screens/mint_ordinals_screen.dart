import 'dart:developer';

import 'package:alpha_go/controllers/mint_ordinal_controller.dart';
import 'package:alpha_go/controllers/wallet_controller.dart';
import 'package:alpha_go/views/widgets/navbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class MintOrdinalsScreen extends StatefulWidget {
  const MintOrdinalsScreen({super.key});

  @override
  State<MintOrdinalsScreen> createState() => _MintOrdinalsScreenState();
}

class _MintOrdinalsScreenState extends State<MintOrdinalsScreen> {
  final MintOrdinalController inscriptionController = MintOrdinalController();
  final WalletController walletController = Get.find();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: CustomNavBar(
            leadingWidget: Row(
              children: [
                IconButton(
                  onPressed: () {
                    context.pop();
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Color(0xffb4914b),
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  'Mint Ordinal',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xffb4914b),
                  ),
                ),
              ],
            ),
            actionWidgets: Container(),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          Map<String, dynamic> inscriptionData =
                              await inscriptionController
                                  .pickPictureAndEncode();
                          if (inscriptionData['success'] == true) {
                            await inscriptionController.inscribe(
                                inscriptionData, walletController.address!, 2);
                            if (inscriptionController.inscriptionModel !=
                                null) {
                              await inscriptionController.fetchOrderDetails(
                                inscriptionController.inscriptionModel!.id,
                              );
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
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Select Image to Mint'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffb4914b),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 5.w, vertical: 2.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  if (inscriptionController.inscriptionModel != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            height: 40.h,
                            width: 100.w,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Image.network(
                              inscriptionController
                                      .inscriptionModel!.inscriptionURL ,
                                  
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        infoRow('Inscription ID',
                            inscriptionController.inscriptionModel!.id),
                        infoRow(
                            'Cost (sats)',
                            inscriptionController.inscriptionModel!.totalFee
                                .toString()),
                        infoRow('Status',
                            inscriptionController.inscriptionModel!.status),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Text(
                                    'Payment Address: ',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Expanded(
                                    child: Text(
                                      inscriptionController.inscriptionModel
                                              ?.paymentAddress ??
                                          "",
                                      style:
                                          const TextStyle(color: Colors.white),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(
                                    text: inscriptionController
                                            .inscriptionModel?.paymentAddress ??
                                        "",
                                  ),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Payment address copied!")),
                                );
                              },
                              icon: const Icon(Icons.copy, color: Colors.white),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              log(inscriptionController.inscriptionModel!.id);
                              walletController.sendSats(
                                inscriptionController
                                    .inscriptionModel!.paymentAddress!,
                                inscriptionController
                                    .inscriptionModel!.totalFee,
                              );
                            },
                            icon: const Icon(Icons.send),
                            label: const Text('Send Payment'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xffb4914b),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6.w, vertical: 2.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget infoRow(String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: const Color(0xffb4914b),
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value ?? '',
            style: const TextStyle(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
