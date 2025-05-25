// import 'package:alpha_go/controllers/ordinal_listing_controller.dart';
// import 'package:alpha_go/controllers/wallet_controller.dart';
// import 'package:alpha_go/models/const_model.dart';
// import 'package:alpha_go/views/widgets/navbar_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:go_router/go_router.dart';
// import 'package:responsive_sizer/responsive_sizer.dart';

// class OrdinalListingScreen extends StatelessWidget {
//   final OrdinalListingController controller =
//       Get.put(OrdinalListingController());
//   final walletController = Get.find<WalletController>();

//   OrdinalListingScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//        decoration: const BoxDecoration(
//         image: DecorationImage(
//           image: AssetImage("assets/bg.jpg"),
//           fit: BoxFit.cover,
//         ),
//       ),
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         appBar: CustomNavBar(
//             leadingWidget: Padding(
//               padding: EdgeInsets.all(1.w),
//               child: IconButton(
//                 onPressed: () => context.pop(),
//                 icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFB4914B)),
//               ),
//             ),
//             actionWidgets: SizedBox(
//               width: 75.w,
//               child: Row(
//                 children: [
//                   Text(
//                     "Create Ordinal Listing",
//                     style: TextStyle(
//                       color: const Color(0xFFB4914B),
//                       fontSize: 18.sp,
//                       fontFamily: 'Cinzel',
//                     ),
//                   ),
//                   const Spacer(),
//                 ],
//               ),
//             ),
//           ),
//         body: Center(
//           child: Obx(() => controller.isLoading.value
//               ? const CircularProgressIndicator()
//               : InkWell(
//                  onTap: () async {
//                     try {
//                       walletController.syncWallet();
//                       controller.isLoading.value = true;
//                       print("▶️ Submitting listing...");
      
//                       final wallet = walletController.wallet;
//                       final descriptor = walletController.descriptorString ;
//                       await walletController.getAddress();
      
//                       print("👜 Wallet: ${wallet != null ? 'Wallet Exists' : 'Wallet doesnt exist'}");
//                       print("🔑 Descriptor object: $descriptor");
//                       print("🔍 Descriptor string: ${descriptor}");
      
//                       if (walletController.address == null) {
//                         print("❌ Wallet address is null"); 
//                       } else {
//                         print("🏠 Seller Address: ${walletController.address}");
//                       }
      
//                       await controller.createPsbtAndListing(
//                         wallet: wallet,
//                         inscriptionId:
//                             '9f597b2af2f520302ace5a189fe52381406c248544aec0b517721b31b4e6c918i0',
//                         txid:
//                             '9f597b2af2f520302ace5a189fe52381406c248544aec0b517721b31b4e6c918',
//                         vout: 0,
//                         utxoValue: BigInt.from(546),
//                         sellerAddress: "bc1pl3sr5ypgklv3xegcth5ufka57lv2n0sqjxmpuzhx2sgh2g9a2drqjrxzam",
//                         price: BigInt.from(1000),
//                         satisfactionWeight: BigInt.from(0),
//                         sellerDescriptor: descriptor!,
//                         metadata: 'SAMPLE ORDINAL',
//                         expiresDays: 15,
//                       );
      
//                       print("📦 PSBT Base64: ${controller.psbtBase64.value}");
//                       print("⚠️ Error Message: ${controller.errorMsg.value}");
      
//                       WidgetsBinding.instance.addPostFrameCallback((_) {
//                         if (controller.psbtBase64.value.isNotEmpty) {
//                           print('✅ Listing created successfully');
//                         } else {
//                           print('❌ Failed to create listing');
//                         }
//                       });
//                     } catch (e) {
//                       print("❌ Exception occurred: $e");
//                       final msg = controller.errorMsg.value.isNotEmpty
//                           ? controller.errorMsg.value
//                           : e.toString();
      
//                       if (Get.context != null) {
//                         WidgetsBinding.instance.addPostFrameCallback((_) {
//                           print("⚠️ Snackbar context is not null. Error: $msg");
//                         });
//                       } else {
//                         print("⚠️ Snackbar context is null. Error: $msg");
//                       }
//                     } finally {
//                       controller.isLoading.value = false;
//                     }
//                   },
      
//                   child: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 4.h),
//                     width: 90.w,
//                     child: ElevatedButton(
//                       onPressed: () {
                       
//                       },
//                       style: Constants.buttonStyle,
//                       child: Text(
//                         "Create Listing",
//                         style: TextStyle(
//                             fontFamily: 'Cinzel',
//                             color: Colors.white,
//                             fontSize: 18.sp),
//                       ),
//                     ),
//                   ),
//                 )),
//         ),
//       ),
//     );
//   }
// }


import 'package:alpha_go/controllers/ordinal_listing_controller.dart';
import 'package:alpha_go/controllers/wallet_controller.dart';
import 'package:alpha_go/models/const_model.dart';
import 'package:alpha_go/views/widgets/navbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class OrdinalListingScreen extends StatelessWidget {
  final OrdinalListingController controller =
      Get.put(OrdinalListingController());
  final walletController = Get.find<WalletController>();

  final TextEditingController inscriptionIdController = TextEditingController();
  final TextEditingController txidController = TextEditingController();
  final TextEditingController voutController = TextEditingController();
  final TextEditingController utxoValueController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController metadataController = TextEditingController();
  final TextEditingController expiresDaysController = TextEditingController();
  final TextEditingController sellerAddressController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController collectionIdController = TextEditingController();
  final TextEditingController collectionNameController =
      TextEditingController();
  final TextEditingController traitsController = TextEditingController();

  OrdinalListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/bg.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomNavBar(
          leadingWidget: Padding(
            padding: EdgeInsets.all(1.w),
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFB4914B)),
            ),
          ),
          actionWidgets: SizedBox(
            width: 75.w,
            child: Row(
              children: [
                Text(
                  "Create Ordinal Listing",
                  style: TextStyle(
                    color: const Color(0xFFB4914B),
                    fontSize: 18.sp,
                    fontFamily: 'Cinzel',
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
        body: Center(
          child: Obx(() => controller.isLoading.value
              ? const CircularProgressIndicator()
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Column(
                    children: [
                      _buildInputField(
                          inscriptionIdController, 'Inscription ID'),
                      _buildInputField(txidController, 'TXID'),
                      _buildInputField(voutController, 'Vout (int)',
                          isNumber: true),
                      _buildInputField(utxoValueController, 'UTXO Value (sats)',
                          isNumber: true),
                      _buildInputField(priceController, 'Price (sats)',
                          isNumber: true),
                      _buildInputField(metadataController, 'Metadata'),
                      _buildInputField(
                          expiresDaysController, 'Expires in (days)',
                          isNumber: true),
                      _buildInputField(
                          sellerAddressController, 'Seller Address'),
                      _buildInputField(nameController, 'Name'),
                      _buildInputField(descriptionController, 'Description'),
                      _buildInputField(collectionIdController, 'Collection ID'),
                      _buildInputField(
                          collectionNameController, 'Collection Name'),
                      _buildInputField(
                          traitsController, 'Traits (key:value,key:value)'),
                      SizedBox(height: 4.h),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            walletController.syncWallet();
                            controller.isLoading.value = true;

                            final wallet = walletController.wallet;
                            final descriptor =
                                walletController.descriptorString;
                            await walletController.getAddress();

                          
                          

                            final traits = traitsController.text
                                .trim()
                                .split(',')
                                .map((pair) {
                              final parts = pair.split(':');
                              return {
                                'trait_type': parts[0].trim(),
                                'value': parts[1].trim(),
                              };
                            }).toList();

                            // await controller.createPsbtAndListing(
                            //   wallet: wallet,
                            //   inscriptionId:
                            //       inscriptionIdController.text.trim(),
                            //   utxo: utxo,
                            //   sellerAddress:
                            //       sellerAddressController.text.trim(),
                            //   price: BigInt.from(
                            //       int.parse(priceController.text.trim())),
                            //   satisfactionWeight: BigInt.from(0),
                            //   sellerDescriptor: descriptor!,
                            //   metadata: metadataController.text.trim(),
                            //   expiresDays:
                            //       int.parse(expiresDaysController.text.trim()),
                            //   name: nameController.text.trim(),
                            //   description: descriptionController.text.trim(),
                            //   traits: traits,
                            //   collectionId: collectionIdController.text.trim(),
                            //   collectionName:
                            //       collectionNameController.text.trim(),
                            // );

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (controller.psbtBase64.value.isNotEmpty) {
                                print('✅ Listing created successfully');
                              } else {
                                print('❌ Failed to create listing');
                              }
                            });
                          } catch (e) {
                            final msg = controller.errorMsg.value.isNotEmpty
                                ? controller.errorMsg.value
                                : e.toString();

                            if (Get.context != null) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                print(
                                    "⚠️ Snackbar context is not null. Error: $msg");
                              });
                            } else {
                              print("⚠️ Snackbar context is null. Error: $msg");
                            }
                          } finally {
                            controller.isLoading.value = false;
                          }
                        },
                        style: Constants.buttonStyle,
                        child: Text(
                          "Create Listing",
                          style: TextStyle(
                            fontFamily: 'Cinzel',
                            color: Colors.white,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint,
      {bool isNumber = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: TextStyle(color: Colors.white, fontFamily: 'Cinzel'),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontFamily: 'Cinzel'),
          filled: true,
          fillColor: Colors.black.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
