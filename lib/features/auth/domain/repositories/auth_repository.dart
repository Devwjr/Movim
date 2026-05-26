import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<void> launchGithubAuth();
  Future<String?> exchangeCodeForToken(String code);
  Future<String?> refreshAccessToken(String refreshToken);
  Future<UserEntity?> getCurrentUser(String token);
  Future<void> logout();
}
