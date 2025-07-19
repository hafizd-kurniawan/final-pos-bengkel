import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String? phone;
  final String? role;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.name,
    this.phone,
    this.role,
  });

  @override
  List<Object?> get props => [email, password, name, phone, role];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthStatusChecked extends AuthEvent {
  const AuthStatusChecked();
}

class AuthTokenRefreshed extends AuthEvent {
  final String token;

  const AuthTokenRefreshed({required this.token});

  @override
  List<Object> get props => [token];
}