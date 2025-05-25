class Utxo {
  final String txid;
  final int vout;
  final int value;

  Utxo({
    required this.txid,
    required this.vout,
    required this.value,
  });

  factory Utxo.fromJson(Map<String, dynamic> json) {
    return Utxo(
      txid: json['txid'],
      vout: json['vout'],
      value: int.parse(json['amount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'txid': txid,
      'vout': vout,
      'amount': value.toString(),
    };
  }
}

class OrdinalListingModel {
  final String inscriptionId;
  final Utxo utxo;
  final String sellerAddress;
  final BigInt price;
  final String psbtInput;
  final String metadata;
  final String status;
  final DateTime expiresAt;
  final DateTime createdAt;
  final DateTime? soldAt;
  final String? txid;

  // New fields
  final String name;
  final String description;
  final List<Map<String, dynamic>> traits;
  final String collectionId;
  final String collectionName;

  OrdinalListingModel({
    required this.inscriptionId,
    required this.utxo,
    required this.sellerAddress,
    required this.price,
    required this.psbtInput,
    required this.metadata,
    required this.status,
    required this.expiresAt,
    required this.createdAt,
    this.soldAt,
    this.txid,
    required this.name,
    required this.description,
    required this.traits,
    required this.collectionId,
    required this.collectionName,
  });

  factory OrdinalListingModel.fromJson(Map<String, dynamic> json) {
    return OrdinalListingModel(
      inscriptionId: json['inscriptionId'],
      utxo: Utxo.fromJson(json['ordinalUtxo']),
      sellerAddress: json['sellerAddress'],
      price: BigInt.parse(json['price']),
      psbtInput: json['psbtSignedBase64'],
      metadata: json['metadata'],
      status: json['status'],
      expiresAt: DateTime.parse(json['expiresAt']),
      createdAt: DateTime.parse(json['createdAt']),
      soldAt: json['soldAt'] != null ? DateTime.parse(json['soldAt']) : null,
      txid: json['txid'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      traits: (json['traits'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          [],
      collectionId: json['collectionId'] ?? '',
      collectionName: json['collectionName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inscriptionId': inscriptionId,
      'ordinalUtxo': {
        ...utxo.toJson(),
        'address': sellerAddress,
      },
      'sellerAddress': sellerAddress,
      'price': price.toString(),
      'psbtSignedBase64': psbtInput,
      'metadata': metadata,
      'status': status,
      'expiresAt': expiresAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'soldAt': soldAt?.toIso8601String(),
      'txid': txid,
      'name': name,
      'description': description,
      'traits': traits,
      'collectionId': collectionId,
      'collectionName': collectionName,
    };
  }
}
