import 'package:workout/models/user_model.dart';

class LoginResponse {
  final UserModel user;
  final TokenPair tokens;

  LoginResponse({required this.user, required this.tokens});

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    user: UserModel.fromJson(json['user']),
    tokens: TokenPair.fromJson(json['tokens']),
  );
}

class TokenPair {
  final String accessToken;
  final String refreshToken;
  final String? expiresAt;

  TokenPair({required this.accessToken, required this.refreshToken, this.expiresAt});

  factory TokenPair.fromJson(Map<String, dynamic> json) => TokenPair(
    accessToken: json['access_token'] ?? '',
    refreshToken: json['refresh_token'] ?? '',
    expiresAt: json['expires_at'],
  );
}
