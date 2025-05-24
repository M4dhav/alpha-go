class TimelinePosts {
  String imageUrl;
  String uid;
  int timestamp;

  TimelinePosts({
    required this.imageUrl,
    required this.uid,
    required this.timestamp,
  });

  TimelinePosts.fromJson(Map<String, dynamic> json)
      : imageUrl = json['imageUrl'],
        uid = json['uid'],
        timestamp = json['timestamp'];

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'uid': uid,
      'timestamp': timestamp,
    };
  }
}
