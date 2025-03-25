class User {
  final String id;
  final String username;
  final String email;
  final String? password;
  final String phone;
  final String? name;
  final String? userUuid;
  final String token;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.password,
    required this.phone,
    this.name,
    this.userUuid,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? json['user_uuid'] as String? ?? '',
      username: json['username'] as String,
      email: json['email'] as String,
      password: json['password'] as String?,
      phone: json['phone'] as String,
      name: json['name'] as String?,
      userUuid: json['user_uuid'] as String?,
      token: json['token'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      if (password != null) 'password': password,
      'phone': phone,
      if (name != null) 'name': name,
      if (userUuid != null) 'user_uuid': userUuid,
      'token': token,
    };
  }
}