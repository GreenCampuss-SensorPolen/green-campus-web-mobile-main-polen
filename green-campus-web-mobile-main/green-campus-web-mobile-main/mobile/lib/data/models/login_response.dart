class LoginResponse {
  final String jwt;
  final String email;
  final String role;
  final String profileImageUrl;
  final String firstName;
  final String lastName;

  LoginResponse({
    required this.jwt,
    required this.email,
    required this.role,
    required this.profileImageUrl,
    required this.firstName,
    required this.lastName,
  });

  // Constructor factory para convertir el JSON en una instancia de la clase
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      jwt: json['jwt'] ?? '',
      email: json['email'] ?? '',
      lastName: json['lastName'] ?? '',
      firstName: json['firstName'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      role: json['role'] ?? '',
    );
  }
}
