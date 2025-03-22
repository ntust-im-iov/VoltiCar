class User {
  final String id;
  final String username;
  final String email;
  String? avatar;
  String? fullName;
  String? phone;
  
  User({
    required this.id,
    required this.username,
    required this.email,
    this.avatar,
    this.fullName,
    this.phone,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      fullName: json['fullName'],
      phone: json['phone'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'email': email,
      'avatar': avatar,
      'fullName': fullName,
      'phone': phone,
    };
  }
} 