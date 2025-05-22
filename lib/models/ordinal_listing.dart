import 'package:cloud_firestore/cloud_firestore.dart';

class OrdinalListing {
  final String id;
  final String psbtBase64;
  final Timestamp? timestamp;
  final String status;
  final String ordinalOutpoint;
  final String value;
  final String sellerAddress;
  final String? buyerAddress;
  final String? broadcastTxid;
  final Timestamp? broadcastTime;

  OrdinalListing({
    required this.id,
    required this.psbtBase64,
    required this.timestamp,
    required this.status,
    required this.ordinalOutpoint,
    required this.value,
    required this.sellerAddress,
    this.buyerAddress,
    this.broadcastTxid,
    this.broadcastTime,
  });

  factory OrdinalListing.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrdinalListing(
      id: doc.id,
      psbtBase64: data['psbtBase64'] ?? '',
      timestamp: data['timestamp'],
      status: data['status'] ?? '',
      ordinalOutpoint: data['ordinalOutpoint'] ?? '',
      value: data['value'] ?? '',
      sellerAddress: data['sellerAddress'] ?? '',
      buyerAddress: data['buyerAddress'],
      broadcastTxid: data['broadcast_txid'],
      broadcastTime: data['broadcast_time'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'psbtBase64': psbtBase64,
      'timestamp': timestamp,
      'status': status,
      'ordinalOutpoint': ordinalOutpoint,
      'value': value,
      'sellerAddress': sellerAddress,
      if (buyerAddress != null) 'buyerAddress': buyerAddress,
      if (broadcastTxid != null) 'broadcast_txid': broadcastTxid,
      if (broadcastTime != null) 'broadcast_time': broadcastTime,
    };
  }
}
