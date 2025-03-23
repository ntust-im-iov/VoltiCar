class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final String phone;
  final String name;
  final String userUuid;

  RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.phone,
    required this.name,
    required this.userUuid,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'phone': phone,
      'name': name,
      'user_uuid': userUuid,
    };
  }
} 