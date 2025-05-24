import 'dart:developer';

class MintOrdinalModel {
  String id;
  int totalFee;
  int serviceFee;
  int chainFee;
  int baseFee;
  int postage;
  int feeRate;
  int additionalFee;
  int inscriptionSize;
  String inscriptionName;
  String inscriptionType;
  String inscriptionURL;
  Map<String, dynamic> inscriptionData;
  String? paymentAddress;
  String? status;
  Map<String, dynamic>? orderData;
  MintOrdinalModel({
    required this.id,
    required this.totalFee,
    required this.serviceFee,
    required this.chainFee,
    required this.baseFee,
    required this.postage,
    required this.feeRate,
    required this.additionalFee,
    required this.inscriptionData,
    required this.orderData,
    required this.inscriptionSize,
    required this.inscriptionName,
    required this.inscriptionType,
    required this.inscriptionURL,
  });
  MintOrdinalModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        totalFee = json['charge']['amount'],
        serviceFee = json['serviceFee'],
        chainFee = json['chainFee'],
        baseFee = json['baseFee'],
        postage = json['postage'],
        feeRate = json['fee'],
        additionalFee = json['additionalFeeCharged'],
        inscriptionData = json,
        inscriptionSize = json['files'][0]['size'],
        inscriptionName = json['files'][0]['name'],
        inscriptionType = json['files'][0]['type'],
        inscriptionURL = json['files'][0]['url'];

  void updateOrderData(Map<String, dynamic> orderData) {
    log('setting data');
    this.orderData = orderData;
    paymentAddress = orderData['charge']['address'];
    status = orderData['state'];
  }
}
