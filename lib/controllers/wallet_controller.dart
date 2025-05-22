import 'dart:convert';
import 'dart:developer';
import 'package:alpha_go/models/const_model.dart';
import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class WalletController extends GetxController {
  late Blockchain blockchain;
  late Wallet ordinalWallet;
  late Wallet fundingWallet;
  String? password;
  String? mnemonic;
  String? ordinalAddress;
  String? fundingAddress;
  int? ordinalWalletBalance;
  int? fundingWalletBalance;
  List<LocalUtxo> unspentTokens = [];
  Map<String, Map<String, dynamic>> ordinals = {};
  Map<String, Map<String, dynamic>> runes = {};
  final Network network = Network.bitcoin;
  List<dynamic> runeBalances = [];
  final int utxoChunkSize = 10;

  Future<void> generateMnemonicHandler() async {
    var res = await Mnemonic.create(WordCount.words12);
    mnemonic = res.toString();
  }

  Future<Blockchain> blockchainInit() async {
    blockchain = await Blockchain.create(
      config: BlockchainConfig.esplora(
          config: EsploraConfig(
        // baseUrl: "https://blockstream.info/api/",
        baseUrl: "https://mempool.space/api",

        stopGap: BigInt.from(5),
        concurrency: 1,
      )),
      // config: BlockchainConfig.electrum(
      //     config: ElectrumConfig(
      //         url: 'ssl://electrum.blockstream.info:60002',
      //         retry: 2,
      //         stopGap: BigInt.from(5),
      //         validateDomain: true)),
    );
    //
    return blockchain;
  }

  Future<List<Descriptor>> getOrdinalDescriptors(String mnemonic) async {
    final descriptors = <Descriptor>[];
    try {
      for (var e in [KeychainKind.externalChain, KeychainKind.internalChain]) {
        final mnemonicObj = await Mnemonic.fromString(mnemonic);
        final descriptorSecretKey = await DescriptorSecretKey.create(
          network: network,
          mnemonic: mnemonicObj,
        );
        final descriptor = await Descriptor.newBip86(
            secretKey: descriptorSecretKey, network: network, keychain: e);
        descriptors.add(descriptor);
      }

      return descriptors;
    } on Exception catch (e) {
      log(e.toString(), name: 'GetDescriptors');
      rethrow;
    }
  }

  Future<void> createOrRestoreOrdinalWallet() async {
    try {
      final descriptors = await getOrdinalDescriptors(mnemonic!);
      await blockchainInit();
      final res = await Wallet.create(
          descriptor: descriptors[0],
          changeDescriptor: descriptors[1],
          network: network,
          databaseConfig: const DatabaseConfig.memory());
      ordinalWallet = res;
      await getOrdinalAddress();
    } on Exception catch (e) {
      log(e.toString(), name: 'CreateOrdinalWallet');
      rethrow;
    }
  }

  Future<List<Descriptor>> getFundingDescriptors(String mnemonic) async {
    final descriptors = <Descriptor>[];
    try {
      for (var e in [KeychainKind.externalChain, KeychainKind.internalChain]) {
        final mnemonicObj = await Mnemonic.fromString(mnemonic);
        final descriptorSecretKey = await DescriptorSecretKey.create(
          network: network,
          mnemonic: mnemonicObj,
        );
        final descriptor = await Descriptor.newBip49(
            secretKey: descriptorSecretKey, network: network, keychain: e);

        descriptors.add(descriptor);
      }
      return descriptors;
    } on Exception catch (e) {
      log(e.toString(), name: 'GetDescriptorsFunding');
      rethrow;
    }
  }

  Future<void> createOrRestoreFundingWallet() async {
    try {
      final descriptors = await getFundingDescriptors(mnemonic!);
      final res = await Wallet.create(
          descriptor: descriptors[0],
          changeDescriptor: descriptors[1],
          network: network,
          databaseConfig: const DatabaseConfig.memory());
      fundingWallet = res;
      await getFundingAddress();
    } on Exception catch (e) {
      log(e.toString(), name: 'CreateWallet');
      rethrow;
    }
  }

  Future<void> getOrdinalAddress() async {
    final addressInfo =
        ordinalWallet.getAddress(addressIndex: const AddressIndex.increase());
    ordinalAddress = addressInfo.address.toString();
  }

  Future<void> getFundingAddress() async {
    final addressInfo =
        fundingWallet.getAddress(addressIndex: const AddressIndex.increase());
    fundingAddress = addressInfo.address.toString();
  }

  Future<void> getOrdinalWalletBalance() async {
    final balanceObj = ordinalWallet.getBalance();
    final res = "Total Balance: ${balanceObj.total.toString()}";
    log(res);
    ordinalWalletBalance = balanceObj.total.toInt();
  }

  Future<void> getFundingWalletBalance() async {
    final balanceObj = fundingWallet.getBalance();
    final res = "Total Balance: ${balanceObj.total.toString()}";
    log(res);
    fundingWalletBalance = balanceObj.total.toInt();
  }

  Future<void> syncWallet() async {
    await ordinalWallet.sync(blockchain: blockchain);
    await fundingWallet.sync(blockchain: blockchain);
    log('Wallet synced');
  }

  Future<void> initWallet() async {
    await syncWallet();
    await getOrdinalWalletBalance();
    await getFundingWalletBalance();
    await getUtxo();
  }

  Future<String> getRuneSymbol(String runeId) async {
    final url = Uri.parse('https://api.hiro.so/runes/v1/etchings/$runeId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['symbol'];
      } else {
        throw Exception(
            'Failed to load symbol. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching balances: $e');
      return '';
    }
  }

  Future<bool> checkRune(LocalUtxo unspentToken) async {
    final url = Uri.parse(
        'https://api.hiro.so/runes/v1/transactions/${unspentToken.outpoint.txid}/activity');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> results = List<Map<String, dynamic>>.from(
            jsonDecode(response.body)['results'] ?? []);
        if (results.isNotEmpty) {
          Map<String, dynamic> rune = results.firstWhere(
            (item) => item["address"] == ordinalAddress,
            orElse: () => {},
          );
          String runeId = rune['rune']['id'].toString();
          if (runes.containsKey(runeId)) {
            runes[runeId]!['balance'] += double.parse(rune['amount']);
            runes[runeId]!['results'].add(rune);
            runes[runeId]!['utxos'].add(unspentToken);
          } else {
            runes[runeId] = {
              'balance': double.parse(rune['amount']),
              'results': [rune],
              'utxos': [unspentToken],
              'symbol': await getRuneSymbol(rune['rune']['id'].toString()),
              'name': rune['rune']['spaced_name'].toString(),
              'id': runeId
            };
          }
          return true;
        } else {
          return false;
        }
        //log(runeBalances.toString());
      } else {
        throw Exception(
            'Failed to load balances. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching balances: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getOrdinalInfo(String ordinalId) async {
    String url = "https://api.ordiscan.com/v1/inscription/$ordinalId";

    var response = await http.get(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer ${Constants.ordiscanApiKey}",
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> results =
          Map<String, dynamic>.from(jsonDecode(response.body)['data']);
      if (results['content_type'].contains('text')) {
        var data = await http.get(Uri.parse(results['content_url']));
        if (data.statusCode == 200) {
          results['contents'] = data.body;
        }
      }

      return results;
    } else {
      log("Request failed with status: ${response.statusCode}");
      return {};
    }
  }

  Future<bool> checkTransferredOrdinal(LocalUtxo unspentToken) async {
    String urlTransfer =
        "https://api.ordiscan.com/v1/tx/${unspentToken.outpoint.txid}/inscription-transfers";

    var response = await http.get(
      Uri.parse(urlTransfer),
      headers: {
        "Authorization": "Bearer ${Constants.ordiscanApiKey}",
      },
    );

    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> results =
            Map<String, dynamic>.from(jsonDecode(response.body)['data'][0]);
        String ordinalId = results['inscription_id'].toString();
        Map<String, dynamic> ordinalInfo = await getOrdinalInfo(ordinalId);
        ordinals[ordinalId] = {
          "info": ordinalInfo,
          "utxos": [unspentToken],
          "transfer_data": results
        };
        return true;
      } on RangeError {
        log('This is not transferred ordinal');
        return false;
      }
    } else {
      log("Request failed with status: ${response.statusCode}");
      return false;
    }
  }

  Future<void> checkCreatedOrdinal(LocalUtxo unspentToken) async {
    String urlCreated =
        "https://api.ordiscan.com/v1/tx/${unspentToken.outpoint.txid}/inscriptions";

    var response = await http.get(
      Uri.parse(urlCreated),
      headers: {
        "Authorization": "Bearer ${Constants.ordiscanApiKey}",
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> results =
          Map<String, dynamic>.from(jsonDecode(response.body)['data'][0]);
      String ordinalId = results['inscription_id'].toString();
      Map<String, dynamic> ordinalInfo = await getOrdinalInfo(ordinalId);
      ordinals[ordinalId] = {
        "info": ordinalInfo,
        "utxos": [unspentToken],
        "transfer_data": results
      };
    } else {
      log("Request failed with status: ${response.statusCode}");
    }
  }

  Future<void> sendSats(String adrStr, int amount) async {
    final TxBuilder txBuilder = TxBuilder();
    final Address receiverAddress =
        await Address.fromString(s: adrStr, network: network);
    final FeeRate fee = await blockchain.estimateFee(target: BigInt.from(1));
    log(fee.satPerVb.roundToDouble().toString());
    final script = receiverAddress.scriptPubkey();
    final psbt = await txBuilder
        .addRecipient(script, BigInt.from(amount))
        // .addUtxo(outpoint)
        .feeRate(1.0)
        .finish(ordinalWallet);

    final sbt = ordinalWallet.sign(psbt: psbt.$1);
    final tx = psbt.$1.extractTx();
    await blockchain.broadcast(transaction: tx);
    log(name: 'txid', tx.txid());
  }

  Future<void> sendUtxos(
    String adrStr,
    int amount,
    List<LocalUtxo> utxos,
  ) async {
    final TxBuilder txBuilder = TxBuilder();

    final Address receiverAddress =
        await Address.fromString(s: adrStr, network: network);
    final FeeRate fee = await blockchain.estimateFee(target: BigInt.from(1));
    log(fee.satPerVb.roundToDouble().toString());
    final script = receiverAddress.scriptPubkey();
    final psbt = await txBuilder
        .addRecipient(script, BigInt.from(amount))
        .doNotSpendChange()
        .addUtxos(List.from(utxos.map((e) => e.outpoint)))
        .feeRate(1.0)
        .finish(ordinalWallet);

    final sbt = ordinalWallet.sign(psbt: psbt.$1);
    final tx = psbt.$1.extractTx();
    await blockchain.broadcast(transaction: tx);
    log(name: 'txid', tx.txid());
  }

  Future<void> getUtxo() async {
    // await syncWallet();
    runes.clear();
    ordinals.clear();
    unspentTokens = ordinalWallet.listUnspent();
    for (var element in unspentTokens) {
      log(element.outpoint.txid);
    }
    if (unspentTokens.isNotEmpty) {
      for (var token in unspentTokens) {
        bool isRune = await checkRune(token);
        if (!isRune) {
          log('checking ordinal');
          bool isTransferredOrdinal = await checkTransferredOrdinal(token);
          if (!isTransferredOrdinal) {
            log('checking created ordinal');
            await checkCreatedOrdinal(token);
          }
        }
      }
      log(runes.toString());
      log(ordinals.toString());
    } else {
      log("No unspent tokens");
    }
  }

  // Future<void> sellerCreateAndStoreTransaction({
  //   required Wallet wallet,
  //   required LocalUtxo ordinalUtxo,
  //   required String sellerReceiveAddress,
  //   required String listingId,
  // }) async {
  //   final builder = TxBuilder()
  //     // ..manuallySelectedOnly()
  //     ..addUtxos([ordinalUtxo.outpoint])
  //     // for (var ordinal in ordinals.values) {
  //     //   if (ordinal['utxos'][0] != ordinalUtxo) {
  //     //     builder.addUnSpendable(ordinal['utxos'][0].outpoint);
  //     //   }
  //     // }
  //     // for (var rune in runes.values) {
  //     //   for (var utxo in rune['utxos']) {
  //     //     builder.addUnSpendable(utxo.outpoint);
  //     //   }
  //     // }
  //     // builder
  //     ..doNotSpendChange()
  //     // ..drainWallet()
  //     ..addRecipient(
  //       (await Address.fromString(
  //               s: sellerReceiveAddress, network: Network.bitcoin))
  //           .scriptPubkey(),
  //       ordinalUtxo.txout.value,
  //     )
  //     ..feeRate(1.0);
  // }) async {
  //   // 1. Get all UTXOs except the ordinal UTXO
  //   final allUtxos = await wallet.listUnspent();
  //   final feeUtxos =
  //       allUtxos.where((u) => u.outpoint != ordinalUtxo.outpoint).toList();

  //   // 2. Build the transaction
  //   final builder = TxBuilder()
  //     ..addUtxos([ordinalUtxo.outpoint]) // Add ordinal UTXO (for transfer)
  //     ..addUtxos(
  //         feeUtxos.map((u) => u.outpoint).toList()) // Add sats UTXOs for fee
  //     ..doNotSpendChange() // Prevent spending change from ordinal UTXO
  //     ..addRecipient(
  //       (await Address.fromString(
  //               s: sellerReceiveAddress, network: Network.bitcoin))
  //           .scriptPubkey(),
  //       ordinalUtxo.txout.value, // Output value must match input exactly!
  //     )
  //     ..feeRate(1.0);

  //   final (psbt, _) = await builder.finish(wallet);
  //   await wallet.sign(psbt: psbt);

  //   final psbtBytes = await psbt.serialize();
  //   final psbtBase64 = base64Encode(psbtBytes);

  //   log('PRINT PSBT          ' + psbtBase64);
  // final listing = OrdinalListing(
  //   id: listingId,
  //   psbtBase64: psbtBase64,
  //   timestamp: null,
  //   status: 'available',
  //   ordinalOutpoint: ordinalUtxo.outpoint.toString(),
  //   value: ordinalUtxo.txout.value.toString(),
  //   sellerAddress: sellerReceiveAddress,
  //   buyerAddress: null,
  //   broadcastTxid: null,
  //   broadcastTime: null,
  // );

  // await FirebaseFirestore.instance
  //     .collection('ordinal_listing')
  //     .doc(listingId)
  //     .set({
  //   ...listing.toMap(),
  //   'timestamp': FieldValue.serverTimestamp(),
  // });

  //   debugPrint("PSBT stored for listing $listingId");
  // }

  Future<void> createBip49Wallet() async {
    final mnemonicObj = await Mnemonic.fromString(mnemonic!);
    final descriptorSecretKey = await DescriptorSecretKey.create(
      network: network,
      mnemonic: mnemonicObj,
    );
    final bip49External = await Descriptor.newBip49(
      secretKey: descriptorSecretKey,
      network: network,
      keychain: KeychainKind.externalChain,
    );
    final bip49Internal = await Descriptor.newBip49(
      secretKey: descriptorSecretKey,
      network: network,
      keychain: KeychainKind.internalChain,
    );
    bip49Wallet = await Wallet.create(
      descriptor: bip49External,
      changeDescriptor: bip49Internal,
      network: network,
      databaseConfig: const DatabaseConfig.memory(),
    );
  }

  Future<void> sellerCreateAndStoreTransactionWithBip49({
    required LocalUtxo ordinalUtxo,
    required String sellerReceiveAddress,
    required String listingId,
  }) async {
    try {
      if (bip49Wallet == null) {
        await createBip49Wallet();
      }
      await bip49Wallet!.sync(blockchain: blockchain);
      final fundingUtxos = await wallet.listUnspent();
      final builder = TxBuilder()
        ..addUtxos([ordinalUtxo.outpoint])
        ..addUtxos(fundingUtxos.map((u) => u.outpoint).toList())
        ..doNotSpendChange()
        ..addRecipient(
          (await Address.fromString(
                  s: sellerReceiveAddress, network: Network.bitcoin))
              .scriptPubkey(),
          ordinalUtxo.txout.value,
        )
        ..feeRate(1.0);
      final (psbt, _) = await builder.finish(bip49Wallet!);
      await bip49Wallet!.sign(psbt: psbt);
      await wallet.sign(psbt: psbt);
      final psbtBytes = await psbt.serialize();
      final psbtBase64 = base64Encode(psbtBytes);
      log('PRINT PSBT (BIP49) ' + psbtBase64);
      debugPrint("PSBT stored for listing $listingId");
    } catch (e, st) {
      log('Error in sellerCreateAndStoreTransactionWithBip49: $e\n$st');
      debugPrint('Error in sellerCreateAndStoreTransactionWithBip49: $e');
    }
  }
  // Future<void> buyerRetrieveAndBroadcast({
  //   required Wallet wallet,
  //   required Blockchain blockchain,
  //   required String listingId,
  //   required String buyerReceiveAddress,
  //   required List<LocalUtxo> buyerUtxos,
  // }) async {
  //   final doc = await FirebaseFirestore.instance
  //       .collection('ordinal_listing')
  //       .doc(listingId)
  //       .get();

  //   final listing = OrdinalListing.fromFirestore(doc);

  //   if (listing.psbtBase64.isEmpty ||
  //       listing.value.isEmpty ||
  //       listing.sellerAddress.isEmpty) {
  //     throw Exception("Incomplete listing data for $listingId");
  //   }

  //   final psbt =
  //       await PartiallySignedTransaction.fromString(listing.psbtBase64);

  //   final buyerAddress = await Address.fromString(
  //       s: buyerReceiveAddress, network: Network.bitcoin);
  //   final script = buyerAddress.scriptPubkey();

  //   final builder = TxBuilder()
  //     ..addUtxos(buyerUtxos.map((e) => e.outpoint).toList())
  //     ..addRecipient(
  //       (await Address.fromString(
  //               s: listing.sellerAddress, network: Network.bitcoin))
  //           .scriptPubkey(),
  //       BigInt.parse(listing.value),
  //     )
  //     ..addRecipient(script, BigInt.from(1)) // Change to buyer (mock value)
  //     ..feeRate(1.5);

  //   final (buyerPsbt, _) = await builder.finish(wallet);

  //   final combinedPsbt = await psbt.combine(buyerPsbt);
  //   await wallet.sign(psbt: combinedPsbt);

  //   final tx = await combinedPsbt.extractTx();
  //   final txId = await blockchain.broadcast(transaction: tx);

  //   await FirebaseFirestore.instance
  //       .collection('ordinal_listing')
  //       .doc(listingId)
  //       .update({
  //     'status': 'sold',
  //     'broadcast_txid': txId,
  //     'broadcast_time': FieldValue.serverTimestamp(),
  //     'buyerAddress': buyerReceiveAddress,
  //   });

  //   debugPrint("Broadcasted txid: $txId for listing $listingId");
  // }
}
