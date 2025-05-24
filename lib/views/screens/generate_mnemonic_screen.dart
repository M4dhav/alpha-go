import 'package:alpha_go/controllers/wallet_controller.dart';
import 'package:alpha_go/models/const_model.dart';
import 'package:alpha_go/views/widgets/navbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class GenerateWalletMnemonic extends StatefulWidget {
  const GenerateWalletMnemonic({super.key});

  @override
  State<GenerateWalletMnemonic> createState() => _GenerateWalletMnemonicState();
}

class _GenerateWalletMnemonicState extends State<GenerateWalletMnemonic> {
  final TextEditingController mnemonic = TextEditingController();
  final WalletController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.generateMnemonicHandler().then((value) {
      setState(() {
        mnemonic.text = controller.mnemonic!;
      });
    });
  }

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
            width: 76.w,
            child: Row(
              children: [
                Text(
                  "Backup your Seed Phrase",
                  style: TextStyle(
                    color: const Color(0xFFB4914B), // Gold color
                    fontSize: 16.sp,
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
              const Text(
                  "Write down your seed phrase and make sure to keep it private. This is the unique key to your wallet."),
              Padding(
                padding: EdgeInsets.only(top: 5.h),
                child: TextFormField(
                    style: const TextStyle(
                        color: Colors.white, fontFamily: 'Roboto'),
                    readOnly: true,
                    cursorColor: Colors.white,
                    controller: mnemonic,
                    //keyboardType: TextInputType.multiline,
                    maxLines: 3,
                    decoration: Constants.inputDecoration.copyWith(
                        hintText: "Seed Phrase",
                        suffixIconColor: const Color(0xffb4914b),
                        suffixIcon: IconButton(
                            onPressed: () async {
                              if (mnemonic.text.isNotEmpty) {
                                await Clipboard.setData(
                                        ClipboardData(text: mnemonic.text))
                                    .then((onCallback) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Seed Phrase copied to clipboard!")),
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
                child: ElevatedButton(
                    style: Constants.buttonStyle,
                    onPressed: () {
                      context.go('/setPassword', extra: [false, false]);
                    },
                    child: const Text("Continue")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
