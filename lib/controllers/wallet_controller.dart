import 'dart:convert';
import 'dart:developer';
import 'package:alpha_go/models/const_model.dart';
import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class WalletController extends GetxController {
  late Blockchain blockchain;
  late Wallet wallet;
  String? password;
  String? mnemonic;
  String? address;
  int? balance;
  String? descriptorString;
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

  Future<List<Descriptor>> getDescriptors(String mnemonic) async {
    final descriptors = <Descriptor>[];
    try {
      for (var e in [KeychainKind.externalChain, KeychainKind.internalChain]) {
        final mnemonicObj = await Mnemonic.fromString(mnemonic);
        final descriptorSecretKey = await DescriptorSecretKey.create(
          network: network,
          mnemonic: mnemonicObj,
        );
        // final descriptor = await Descriptor.newBip84(
        //   secretKey: descriptorSecretKey,
        //   network: Network.bitcoin,
        //   keychain: e,
        // );
        final descriptor = await Descriptor.newBip86(
            secretKey: descriptorSecretKey, network: network, keychain: e);
        // final descriptor = await Descriptor.create(descriptor: '', network: Network.bitcoin);
        descriptors.add(descriptor);
        
      }
      descriptorString =  descriptors[0].asString();
      return descriptors;
    } on Exception catch (e) {
      log(e.toString(), name: 'GetDescriptors');
      rethrow;
    }
  }

  Future<void> createOrRestoreWallet() async {
    try {
      final descriptors = await getDescriptors(mnemonic!);
      await blockchainInit();
      final res = await Wallet.create(
          descriptor: descriptors[0],
          changeDescriptor: descriptors[1],
          network: network,
          databaseConfig: const DatabaseConfig.memory());
      wallet = res;
      await getAddress();
    } on Exception catch (e) {
      log(e.toString(), name: 'CreateWallet');
      rethrow;
    }
  }

  Future<void> getAddress() async {
    final addressInfo =
        wallet.getAddress(addressIndex: const AddressIndex.increase());
    address = addressInfo.address.toString();
  }

  Future<void> getBalance() async {
    await syncWallet();
    final balanceObj = wallet.getBalance();
    final res = "Total Balance: ${balanceObj.total.toString()}";
    log(res);
    balance = balanceObj.total.toInt();
  }

  Future<void> syncWallet() async {
    await wallet.sync(blockchain: blockchain);
    log('Wallet synced');
  }

  Future<void> initWallet() async {
    await syncWallet();
    await getBalance();
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
            (item) => item["address"] == address,
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
      } on RangeError catch (e) {
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
        .finish(wallet);

    final sbt = wallet.sign(psbt: psbt.$1);
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
        .finish(wallet);

    final sbt = wallet.sign(psbt: psbt.$1);
    final tx = psbt.$1.extractTx();
    await blockchain.broadcast(transaction: tx);
    log(name: 'txid', tx.txid());
  }

  Future<void> createInscription() async {}

  Future<void> getUtxo() async {
    // await syncWallet();
    runes.clear();
    ordinals.clear();
    unspentTokens = wallet.listUnspent();
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
}
