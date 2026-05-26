import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../core/data/repositories/file_repository.dart';
import 'terminal_service.dart';
import 'github_service.dart';
import 'git_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  getIt.registerLazySingleton<FlutterSecureStorage>(() => secureStorage);

  getIt.registerLazySingleton<GithubService>(() => GithubService(
    secureStorage: getIt(),
  ));

  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
    githubService: getIt(),
    secureStorage: getIt(),
  ));

  getIt.registerLazySingleton<FileRepository>(() => FileRepositoryImpl());

  getIt.registerLazySingleton<TerminalService>(() => TerminalService());

  getIt.registerLazySingleton<GitService>(() => GitService());
}
