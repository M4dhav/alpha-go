// lib/controllers/ordinal_listing_controller.dart
import 'package:alpha_go/models/sample_ordinal_model.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrdinalListingController extends GetxController {
  var isLoading = false.obs;
  var errorMsg = ''.obs;
  var psbtBase64 = ''.obs;
Future<void> createPsbtAndListing({
    required Wallet wallet,
    required String inscriptionId,
    required String txid,
    required int vout,
    required BigInt utxoValue,
    required String sellerAddress,
    required BigInt price,
    required BigInt satisfactionWeight,
    required String sellerDescriptor,
    String? changeDescriptor,
    String metadata = '',
    int expiresDays = 1,
  }) async {
    isLoading.value = true;
    errorMsg.value = '';
    psbtBase64.value = '';

    print("🔄 Starting createPsbtAndListing...");

    try {
      
      
      final txBuilder = TxBuilder();

      final outpoint = OutPoint(txid: txid, vout: vout);
      final sellerAddr =
          await Address.fromString(s: sellerAddress, network: Network.bitcoin);
      final sellerScript =  sellerAddr.scriptPubkey();

      final txOut = TxOut(value: utxoValue, scriptPubkey: sellerScript);

      // Add the UTXO (ordinal) input
      await txBuilder.addUtxo(outpoint); // since it belongs to seller wallet
      print("➕ Added owned UTXO to TxBuilder");

      // Add dummy output that buyer will replace
      final dummyScript = ScriptBuf(
          bytes: Uint8List.fromList([0x6a])); // OP_RETURN dummy output
      txBuilder.addRecipient(dummyScript, BigInt.zero);
      print("➕ Added dummy OP_RETURN output");

      // Build the PSBT with 1 sat/byte fee rate
      final (psbt, _) = await txBuilder.feeRate(1.0).finish(wallet);
      print("✅ PSBT created");

      // Sign only the input — since seller is only signing their UTXO
      final signed = await wallet.sign(psbt: psbt);
      print("🖊️ PSBT signed (input only)");

      // Serialize to Base64 to save for buyer
      final psbtB64 = signed.toString();
      psbtBase64.value = psbtB64;
      print("📦 PSBT Base64: ${psbtB64.substring(0, 20)}...");

      // Save listing with PSBT to Firestore
      final listing = OrdinalListingModel(
        inscriptionId: inscriptionId,
        utxo: Utxo(txid: txid, vout: vout, value: utxoValue.toInt()),
        sellerAddress: sellerAddress,
        price: price,
        psbtInput: psbtB64,
        metadata: metadata,
        status: 'LISTED',
        expiresAt: DateTime.now().add(Duration(days: expiresDays)),
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('ordinal_listing')
          .add(listing.toJson());
      print("✅ Listing saved to Firestore");
    } catch (e) {
      print("❌ Error in createPsbtAndListing: $e");
      errorMsg.value = e.toString();
    } finally {
      isLoading.value = false;
      print("✅ createPsbtAndListing completed");
    }
  }


  Future<List<OrdinalListingModel>> fetchAllListings() async {
    print("📡 Fetching all listings...");
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('ordinal_listing')
          .where('status', isEqualTo: 'LISTED')
          .orderBy('createdAt', descending: true)
          .get();

      print("✅ Listings fetched: ${snapshot.docs.length} documents");
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return OrdinalListingModel.fromJson(data);
      }).toList();
    } catch (e, stack) {
      print("❌ Error fetching listings: $e\n$stack");
      errorMsg.value = 'Error fetching listings: $e';
      return [];
    }
  }
}
 



//  import 'package:alpha_go/models/sample_ordinal_model.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:bdk_flutter/bdk_flutter.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class OrdinalListingController extends GetxController {
//   var isLoading = false.obs;
//   var errorMsg = ''.obs;
//   var psbtBase64 = ''.obs;

//   Future<void> createPsbtAndListing({
//     required Wallet wallet,
//     required String inscriptionId,
//     required String txid,
//     required int vout,
//     required BigInt utxoValue,
//     required String sellerAddress,
//     required BigInt price,
//     required BigInt satisfactionWeight,
//     required String sellerDescriptor,
//     String? changeDescriptor,
//     String metadata = '',
//     int expiresDays = 1,
//   }) async {
//     isLoading.value = true;
//     errorMsg.value = '';
//     psbtBase64.value = '';

//     print("🔄 Starting createPsbtAndListing...");
//     print("📝 Inputs:");
//     print("- txid: $txid");
//     print("- vout: $vout");
//     print("- utxoValue: $utxoValue");
//     print("- sellerAddress: $sellerAddress");
//     print("- price: $price");
//     print("- satisfactionWeight: $satisfactionWeight");

//     try {
//       // Create the transaction builder
//       final txBuilder = TxBuilder();
//       print("✅ TxBuilder initialized");

//       // Prepare OutPoint
//       final outpoint = OutPoint(txid: txid, vout: vout);

//       // -- ❌ Original code (does not work) --
//       /*
//       final sellerAddr =
//           await Address.fromString(s: sellerAddress, network: Network.bitcoin);
//       final sellerScript = await sellerAddr.scriptPubkey();
//       final txOut = TxOut(value: utxoValue, scriptPubkey: sellerScript);
//       final input = await Input(s: txOut.toString());
//       txBuilder.addForeignUtxo(input, outpoint, satisfactionWeight);
//       */

//       // ✅ Workaround: Create dummy PSBT to extract Input
//       final sellerAddr =
//           await Address.fromString(s: sellerAddress, network: Network.bitcoin);
//       final scriptPubkey = await sellerAddr.scriptPubkey();

//       final dummyPsbtJson = '''
//       {
//         "unsigned_tx": {
//           "version": 2,
//           "lock_time": 0,
//           "input": [{
//             "previous_output": {
//               "txid": "$txid",
//               "vout": $vout
//             },
//             "script_sig": "",
//             "sequence": 4294967295
//           }],
//           "output": []
//         },
//         "inputs": [{
//           "witness_utxo": {
//             "script_pubkey": "${scriptPubkey.toString()}",
//             "value": ${utxoValue.toInt()}
//           }
//         }],
//         "outputs": []
//       }
//       ''';

//       final dummyPsbt = await Psbt.deserialize(json: dummyPsbtJson);
//       final input = (await dummyPsbt.inputs())[0];

//       txBuilder.addForeignUtxo(input, outpoint, satisfactionWeight);
//       print("➕ Added foreign UTXO to TxBuilder using workaround");

//       // Add dummy output to satisfy PSBT validity
//       Uint8List bytes = Uint8List.fromList([0]);
//       final dummyScript = ScriptBuf(bytes: bytes);
//       txBuilder.addRecipient(dummyScript, BigInt.from(0));
//       print("➕ Added dummy recipient for PSBT validity");

//       // Build PSBT
//       print("⚙️ Building PSBT...");
//       final txBuilderResult = await txBuilder.feeRate(1.0).finish(wallet);
//       final partiallySigned = txBuilderResult.$1;
//       print("✅ PSBT built successfully");

//       // Sign PSBT
//       final signed = await wallet.sign(psbt: partiallySigned);
//       final psbtB64 = signed.toString();
//       psbtBase64.value = psbtB64;
//       print("🖊️ PSBT signed. Base64: ${psbtB64.substring(0, 20)}...");

//       // Create listing model
//       final listing = OrdinalListingModel(
//         inscriptionId: inscriptionId,
//         utxo: Utxo(txid: txid, vout: vout, value: utxoValue.toInt()),
//         sellerAddress: sellerAddress,
//         price: price,
//         psbtInput: psbtB64,
//         metadata: metadata,
//         status: 'LISTED',
//         expiresAt: DateTime.now().add(Duration(days: expiresDays)),
//         createdAt: DateTime.now(),
//       );
//       print("🧾 Listing object created");

//       // Save listing to Firestore
//       try {
//         await FirebaseFirestore.instance
//             .collection('ordinal_listing')
//             .add(listing.toJson());
//         print("✅ Listing saved to Firestore");
//       } catch (e) {
//         print("❌ Firestore error: $e");
//         errorMsg.value = 'Firestore error: $e';
//       }
//     } catch (e) {
//       print("❌ Error in createPsbtAndListing: $e");
//       errorMsg.value = e.toString();
//     } finally {
//       isLoading.value = false;
//       print("✅ createPsbtAndListing completed");
//     }
//   }

//   Future<List<OrdinalListingModel>> fetchAllListings() async {
//     print("📡 Fetching all listings...");
//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collection('ordinal_listing')
//           .where('status', isEqualTo: 'LISTED')
//           .orderBy('createdAt', descending: true)
//           .get();

//       print("✅ Listings fetched: ${snapshot.docs.length} documents");
//       return snapshot.docs.map((doc) {
//         final data = doc.data();
//         return OrdinalListingModel.fromJson(data);
//       }).toList();
//     } catch (e, stack) {
//       print("❌ Error fetching listings: $e\n$stack");
//       errorMsg.value = 'Error fetching listings: $e';
//       return [];
//     }
//   }
// }
