import 'dart:developer';

import 'package:alpha_go/models/wallet_model.dart';
import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:get/get.dart';

class WalletController extends GetxController {
  late Blockchain blockchain;
  BitcoinWallet? genWallet;
  String? password;
  String? mnemonic;
  String? address;
  int? balance;

  Future<void> generateMnemonicHandler() async {
    var res = await Mnemonic.create(WordCount.Words12);
    mnemonic = res.toString();
  }

  Future<Blockchain> blockchainInit() async {
    blockchain = await Blockchain.create(
        //     config: const BlockchainConfig.esplora(
        //         config: EsploraConfig(
        //   baseUrl: "https://blockstream.info/testnet/api",
        //   stopGap: 5,
        //   concurrency: 1,
        // ))
        config: const BlockchainConfig.electrum(
            config: ElectrumConfig(
                url: 'ssl://electrum.blockstream.info:60002',
                retry: 2,
                stopGap: 5,
                validateDomain: true)));
    return blockchain;
  }

  Future<List<Descriptor>> getDescriptors(String mnemonic) async {
    final descriptors = <Descriptor>[];
    try {
      for (var e in [KeychainKind.External, KeychainKind.Internal]) {
        final mnemonicObj = await Mnemonic.fromString(mnemonic);
        final descriptorSecretKey = await DescriptorSecretKey.create(
          network: Network.Testnet,
          mnemonic: mnemonicObj,
        );
        final descriptor = await Descriptor.newBip84(
          secretKey: descriptorSecretKey,
          network: Network.Testnet,
          keychain: e,
        );
        descriptors.add(descriptor);
      }
      return descriptors;
    } on Exception catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> createOrRestoreWallet(
    Network network,
  ) async {
    try {
      final descriptors = await getDescriptors(mnemonic!);
      await blockchainInit();
      final res = await Wallet.create(
          descriptor: descriptors[0],
          changeDescriptor: descriptors[1],
          network: network,
          databaseConfig: const DatabaseConfig.memory());
      genWallet = BitcoinWallet(res);
      await getAddress();
    } on Exception catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> getAddress() async {
    final addressInfo =
        await genWallet!.wallet.getAddress(addressIndex: const AddressIndex());
    address = addressInfo.address;
  }

  Future<void> getBalance() async {
    syncWallet();
    final balanceObj = await genWallet!.wallet.getBalance();
    final res = "Total Balance: ${balanceObj.total.toString()}";
    log(res);
    balance = balanceObj.total;
  }

  Future<void> syncWallet() async {
    genWallet!.wallet.sync(blockchain);
  }
}
