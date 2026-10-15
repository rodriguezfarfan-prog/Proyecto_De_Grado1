import 'package:dartz/dartz.dart';
import '/core/usecase.dart';
import '/core/errors/failure.dart';
import '/domain/usuario/entities/usuario.dart';
import '/domain/usuario/repositories/auth_repository.dart';

class RegistrarParams {
  final String nombre;
  final String email;
  final String password;
  const RegistrarParams({
    required this.nombre,
    required this.email,
    required this.password,
  });
}

class RegistrarUsuario implements UseCase<Usuario, RegistrarParams> {
  final AuthRepository repository;
  RegistrarUsuario(this.repository);

  @override
  Future<Either<Failure, Usuario>> call(RegistrarParams params) {
    return repository.registro(params.nombre, params.email, params.password);
  }
}
