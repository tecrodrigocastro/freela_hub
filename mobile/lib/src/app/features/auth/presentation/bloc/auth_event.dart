part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final LoginParams params;

  const AuthLoginRequested({
    required this.params,
  });

  @override
  List<Object> get props => [params];
}

class AuthRegisterRequested extends AuthEvent {
  final RegisterParams params;

  const AuthRegisterRequested({
    required this.params,
  });

  @override
  List<Object> get props => [params];
}

class AuthSessionChecked extends AuthEvent {
  const AuthSessionChecked();
}
