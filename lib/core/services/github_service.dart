import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class GithubService {
  final FlutterSecureStorage _secureStorage;

  GithubService({required FlutterSecureStorage secureStorage})
      : _secureStorage = secureStorage;

  String getAuthorizationUrl() {
    final scopes = AppConstants.githubScopes.join(' ');
    final params = {
      'client_id': AppConstants.githubClientId,
      'redirect_uri': AppConstants.githubRedirectUri,
      'scope': scopes,
      'allow_signup': 'true',
    };
    
    final uri = Uri.https('github.com', '/login/oauth/authorize', params);
    return uri.toString();
  }

  Future<void> launchAuthUrl() async {
    final authUrl = getAuthorizationUrl();
    final uri = Uri.parse(authUrl);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw Exception('Não foi possível abrir o navegador');
    }
  }

  Future<String?> exchangeCodeForToken(String code) async {
    final response = await http.post(
      Uri.https('github.com', '/login/oauth/access_token'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'client_id': AppConstants.githubClientId,
        'client_secret': AppConstants.githubClientSecret,
        'code': code,
        'redirect_uri': AppConstants.githubRedirectUri,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final accessToken = data['access_token'] as String?;
      final refreshToken = data['refresh_token'] as String?;
      
      if (refreshToken != null) {
        await _secureStorage.write(
          key: 'github_refresh_token',
          value: refreshToken,
        );
      }
      
      return accessToken;
    }
    
    throw Exception('Falha ao trocar código por token: ${response.statusCode}');
  }

  Future<String?> refreshAccessToken(String refreshToken) async {
    final response = await http.post(
      Uri.https('github.com', '/login/oauth/access_token'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'client_id': AppConstants.githubClientId,
        'client_secret': AppConstants.githubClientSecret,
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final accessToken = data['access_token'] as String?;
      final newRefreshToken = data['refresh_token'] as String?;
      
      if (newRefreshToken != null) {
        await _secureStorage.write(
          key: 'github_refresh_token',
          value: newRefreshToken,
        );
      }
      
      return accessToken;
    }
    
    throw Exception('Falha ao renovar token: ${response.statusCode}');
  }

  Future<Map<String, dynamic>?> getCurrentUser(String token) async {
    final response = await http.get(
      Uri.https('api.github.com', '/user'),
      headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github+json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    
    throw Exception('Falha ao obter usuário: ${response.statusCode}');
  }

  Future<List<Map<String, dynamic>>> getUserRepos(String token) async {
    final response = await http.get(
      Uri.https('api.github.com', '/user/repos', {
        'sort': 'updated',
        'per_page': '100',
      }),
      headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github+json',
      },
    );

    if (response.statusCode == 200) {
      final data = (jsonDecode(response.body) as List<dynamic>).cast<Map<String, dynamic>>();
      return data;
    }
    
    throw Exception('Falha ao obter repositórios: ${response.statusCode}');
  }

  Future<Map<String, dynamic>?> getRepoContents(
    String token,
    String owner,
    String repo,
    String path,
  ) async {
    final response = await http.get(
      Uri.https('api.github.com', '/repos/$owner/$repo/contents/$path'),
      headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github+json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    
    return null;
  }

  Future<String?> getFileContent(
    String token,
    String owner,
    String repo,
    String path,
  ) async {
    final content = await getRepoContents(token, owner, repo, path);
    
    if (content != null && content['encoding'] == 'base64') {
      final base64Content = content['content'] as String;
      final decoded = utf8.decode(base64.decode(base64Content.replaceAll('\n', '')));
      return decoded;
    }
    
    return null;
  }

  Future<void> createGist(
    String token, {
    required String description,
    required bool isPublic,
    required Map<String, String> files,
  }) async {
    final response = await http.post(
      Uri.https('api.github.com', '/gists'),
      headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github+json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'description': description,
        'public': isPublic,
        'files': files.map((key, value) => MapEntry(key, {'content': value})),
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Falha ao criar gist: ${response.statusCode}');
    }
  }
}
