import 'dart:developer';

import 'package:alpha_go/controllers/wallet_controller.dart';
import 'package:alpha_go/models/const_model.dart';
import 'package:alpha_go/views/widgets/navbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SendTokenScreen extends StatefulWidget {
  const SendTokenScreen({super.key, required this.tokenData});
  final Map<String, dynamic> tokenData;

  @override
  State<SendTokenScreen> createState() => _SendTokenScreenState();
}

class _SendTokenScreenState extends State<SendTokenScreen> {
  final WalletController controller = Get.find();
  final TextEditingController addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/bg.jpg'),
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
                    Get.back();
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Color(0xffb4914b),
                  )),
               SizedBox(width: 2.w),
              Text(
                'Send Tokens',
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
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.h),

              // Title
              Text(
                "Enter Receiver's Address",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4.h),

              // Address Input
              TextFormField(
                style: Constants.inputStyle,
                cursorColor: Colors.white,
                decoration: Constants.inputDecoration.copyWith(
                  labelText: 'Receiver Address',
                  labelStyle: const TextStyle(color: Colors.white),
                ),
                maxLines: 1,
                controller: addressController,
              ),

              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 7.h),
                  child: ElevatedButton(
                      style: Constants.buttonStyle,
                      onPressed: () async {
                        log('starting transanction');
                        controller.sendUtxos(addressController.text, 546,
                            widget.tokenData['utxos']);
                        log(List.from(widget.tokenData['utxos']
                            .map((e) => e.outpoint)).toString());
                      },
                      child: const Text('SEND')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
