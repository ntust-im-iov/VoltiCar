class User {
  final String id;
  final String username;
  final String email;
  final String? password;
  final String? phone;
  final String? name;
  final String? userUuid;
  final String token;
  final String? photoUrl;
  final bool isEmailVerified;
  final bool isGoogleUser;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.password,
    this.phone,
    this.name,
    this.userUuid,
    required this.token,
    this.photoUrl,
    this.isEmailVerified = false,
    this.isGoogleUser = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      password: json['password'],
      phone: json['phone'],
      name: json['name'],
      userUuid: json['user_uuid'],
      token: json['token'] ?? '',
      photoUrl: json['photo_url'],
      isEmailVerified: json['is_email_verified'] ?? false,
      isGoogleUser: json['is_google_user'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      if (password != null) 'password': password,
      if (phone != null) 'phone': phone,
      if (name != null) 'name': name,
      if (userUuid != null) 'user_uuid': userUuid,
      'token': token,
      if (photoUrl != null) 'photo_url': photoUrl,
      'is_email_verified': isEmailVerified,
      'is_google_user': isGoogleUser,
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? password,
    String? phone,
    String? name,
    String? userUuid,
    String? token,
    String? photoUrl,
    bool? isEmailVerified,
    bool? isGoogleUser,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      userUuid: userUuid ?? this.userUuid,
      token: token ?? this.token,
      photoUrl: photoUrl ?? this.photoUrl,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isGoogleUser: isGoogleUser ?? this.isGoogleUser,
    );
  }
}
