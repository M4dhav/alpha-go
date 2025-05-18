class OrdinalCollectionModel {
  final String name;
  final String slug;
  final String description;
  final String? twitterLink;
  final String? discordLink;
  final String? websiteLink;
  final int itemCount;

  OrdinalCollectionModel({
    required this.name,
    required this.slug,
    required this.description,
    required this.itemCount,
    this.twitterLink,
    this.discordLink,
    this.websiteLink,
  });

  factory OrdinalCollectionModel.fromMap(Map<String, dynamic> map) {
    return OrdinalCollectionModel(
      name: map['name'] ?? '',
      slug: map['slug'] ?? '',
      description: map['description'] ?? '',
      itemCount: map['item_count'] ?? 0,
      twitterLink: map['twitter_link'],
      discordLink: map['discord_link'],
      websiteLink: map['website_link'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'slug': slug,
      'description': description,
      'item_count': itemCount,
      'twitter_link': twitterLink,
      'discord_link': discordLink,
      'website_link': websiteLink,
    };
  }
}
