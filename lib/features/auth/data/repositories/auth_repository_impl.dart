import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/services/github_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final GithubService _githubService;
  final FlutterSecureStorage _secureStorage;

  AuthRepositoryImpl({
    required GithubService githubService,
    required FlutterSecureStorage secureStorage,
  })  : _githubService = githubService,
        _secureStorage = secureStorage;

  @override
  Future<void> launchGithubAuth() async {
    await _githubService.launchAuthUrl();
  }

  @override
  Future<String?> exchangeCodeForToken(String code) async {
    return _githubService.exchangeCodeForToken(code);
  }

  @override
  Future<String?> refreshAccessToken(String refreshToken) async {
    return _githubService.refreshAccessToken(refreshToken);
  }

  @override
  Future<UserEntity?> getCurrentUser(String token) async {
    final userData = await _githubService.getCurrentUser(token);
    
    if (userData == null) return null;

    return UserEntity(
      id: userData['id'].toString(),
      login: userData['login'] as String,
      name: userData['name'] as String?,
      email: userData['email'] as String?,
      avatarUrl: userData['avatar_url'] as String?,
      bio: userData['bio'] as String?,
      location: userData['location'] as String?,
      company: userData['company'] as String?,
      blog: userData['blog'] as String?,
      htmlUrl: userData['html_url'] as String?,
      followers: userData['followers'] as int? ?? 0,
      following: userData['following'] as int? ?? 0,
      publicRepos: userData['public_repos'] as int? ?? 0,
      createdAt: DateTime.parse(userData['created_at'] as String),
      updatedAt: DateTime.parse(userData['updated_at'] as String),
    );
  }

  @override
  Future<void> logout() async {
    await _secureStorage.delete(key: 'github_token');
    await _secureStorage.delete(key: 'github_refresh_token');
  }
}
