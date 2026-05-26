import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckStatus extends AuthEvent {
  const AuthCheckStatus();
}

class AuthLoginWithGithub extends AuthEvent {
  const AuthLoginWithGithub();
}

class AuthLogout extends AuthEvent {
  const AuthLogout();
}

class AuthHandleCallback extends AuthEvent {
  final Uri uri;

  const AuthHandleCallback(this.uri);

  @override
  List<Object?> get props => [uri];
}

class AuthRefreshToken extends AuthEvent {
  const AuthRefreshToken();
}
