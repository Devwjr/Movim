import 'package:bloc/bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final FlutterSecureStorage _secureStorage;

  AuthBloc({
    required AuthRepository authRepository,
    required FlutterSecureStorage secureStorage,
  })  : _authRepository = authRepository,
        _secureStorage = secureStorage,
        super(const AuthInitial()) {
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthLoginWithGithub>(_onLoginWithGithub);
    on<AuthLogout>(_onLogout);
    on<AuthHandleCallback>(_onHandleCallback);
    on<AuthRefreshToken>(_onRefreshToken);
  }

  Future<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final token = await _secureStorage.read(key: 'github_token');
      
      if (token == null) {
        emit(const Unauthenticated());
        return;
      }

      final user = await _authRepository.getCurrentUser(token);
      
      if (user != null) {
        emit(Authenticated(user: user, token: token));
      } else {
        emit(const Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(const Unauthenticated());
    }
  }

  Future<void> _onLoginWithGithub(
    AuthLoginWithGithub event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      await _authRepository.launchGithubAuth();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onHandleCallback(
    AuthHandleCallback event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final code = event.uri.queryParameters['code'];
      
      if (code == null) {
        emit(const AuthError('Código de autorização não encontrado'));
        return;
      }

      final token = await _authRepository.exchangeCodeForToken(code);
      
      if (token == null) {
        emit(const AuthError('Falha ao obter token de acesso'));
        return;
      }

      await _secureStorage.write(key: 'github_token', value: token);

      final user = await _authRepository.getCurrentUser(token);
      
      if (user != null) {
        emit(Authenticated(user: user, token: token));
      } else {
        emit(const AuthError('Falha ao obter dados do usuário'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(
    AuthLogout event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await _secureStorage.delete(key: 'github_token');
      emit(const Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRefreshToken(
    AuthRefreshToken event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! Authenticated) return;

    try {
      final currentState = state as Authenticated;
      final refreshToken = await _secureStorage.read(key: 'github_refresh_token');
      
      if (refreshToken != null) {
        final newToken = await _authRepository.refreshAccessToken(refreshToken);
        
        if (newToken != null) {
          await _secureStorage.write(key: 'github_token', value: newToken);
          emit(currentState.copyWith(token: newToken));
        }
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
