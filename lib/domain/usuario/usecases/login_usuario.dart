import 'package:dartz/dartz.dart';
import '/core/usecase.dart';
import '/core/errors/failure.dart';
import '/domain/usuario/entities/usuario.dart';
import '/domain/usuario/repositories/auth_repository.dart';

class LoginParams {
  final String email;
  final String password;
  const LoginParams({required this.email, required this.password});
}

class LoginUsuario implements UseCase<Usuario, LoginParams> {
  final AuthRepository repository;
  LoginUsuario(this.repository);

  @override
  Future<Either<Failure, Usuario>> call(LoginParams params) {
    return repository.login(params.email, params.password);
  }
}
