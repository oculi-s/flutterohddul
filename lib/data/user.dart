class User {
  final String uid;
  final String id;
  final List<String> favs;
  final Map<String, dynamic> meta;
  final Map<String, dynamic> price;

  User({
    required this.uid,
    required this.id,
    required this.favs,
    required this.meta,
    required this.price,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'],
      id: json['id'],
      favs: List<String>.from(json['favs']),
      meta: Map<String, dynamic>.from(json['meta']),
      price: Map<String, dynamic>.from(json['price']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'id': id,
      'favs': favs,
      'meta': meta,
      'price': price,
    };
  }
}
