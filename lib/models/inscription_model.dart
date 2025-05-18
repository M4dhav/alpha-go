class OrdinalInscription {
  final String inscriptionId;
  final int inscriptionNumber;
  final String contentType;
  final String ownerAddress;
  final String ownerOutput;
  final DateTime timestamp;
  final String contentUrl;

  // ✅ Additional fields from the /inscription/{id} endpoint
  final String genesisAddress;
  final int sat;
  final String? metaprotocol;
  final String? satsName;

  OrdinalInscription({
    required this.inscriptionId,
    required this.inscriptionNumber,
    required this.contentType,
    required this.ownerAddress,
    required this.ownerOutput,
    required this.timestamp,
    required this.contentUrl,
    required this.genesisAddress,
    required this.sat,
    this.metaprotocol,
    this.satsName,
  });

  factory OrdinalInscription.fromMap(Map<String, dynamic> map) {
    return OrdinalInscription(
      inscriptionId: map['inscription_id'] ?? '',
      inscriptionNumber: map['inscription_number'] ?? 0,
      contentType: map['content_type'] ?? '',
      ownerAddress: map['owner_address'] ?? '',
      ownerOutput: map['owner_output'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      contentUrl: map['content_url'] ?? '',
      genesisAddress: map['genesis_address'] ?? '',
      sat: map['sat'] ?? 0,
      metaprotocol: map['metaprotocol'], // nullable
      satsName: map['sats_name'], // nullable
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'inscription_id': inscriptionId,
      'inscription_number': inscriptionNumber,
      'content_type': contentType,
      'owner_address': ownerAddress,
      'owner_output': ownerOutput,
      'timestamp': timestamp.toIso8601String(),
      'content_url': contentUrl,
      'genesis_address': genesisAddress,
      'sat': sat,
      'metaprotocol': metaprotocol,
      'sats_name': satsName,
    };
  }
}
