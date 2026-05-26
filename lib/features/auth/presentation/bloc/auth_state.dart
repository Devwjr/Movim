import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final UserEntity user;
  final String token;

  const Authenticated({
    required this.user,
    required this.token,
  });

  @override
  List<Object?> get props => [user, token];

  Authenticated copyWith({
    UserEntity? user,
    String? token,
  }) {
    return Authenticated(
      user: user ?? this.user,
      token: token ?? this.token,
    );
  }
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
