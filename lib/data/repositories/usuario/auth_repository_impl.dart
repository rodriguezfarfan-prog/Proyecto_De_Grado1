import 'package:dartz/dartz.dart';
import '/core/errors/failure.dart';
import '/data/datasources/remote/auth_remote_datasource.dart';
import '/domain/usuario/entities/usuario.dart';
import '/domain/usuario/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  String? _userId;
  String? _userName;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Usuario>> login(String email, String password) async {
    try {
      final model = await remoteDataSource.login(email, password);
      _userId = model.id;
      _userName = model.nombre;
      final usuario = model.toDomain();
      return Right(usuario);
    } catch (e) {
      return Left(ServerFailure('Error al iniciar sesión: $e'));
    }
  }

  @override
  Future<Either<Failure, Usuario>> registro(
    String nombre,
    String email,
    String password,
  ) async {
    try {
      final model = await remoteDataSource.registro(nombre, email, password);
      _userId = model.id;
      _userName = model.nombre;
      final usuario = model.toDomain();
      return Right(usuario);
    } catch (e) {
      return Left(ServerFailure('Error al registrarse: $e'));
    }
  }

  @override
  Future<void> logout() async {
    _userId = null;
    _userName = null;
  }

  @override
  Future<String?> obtenerUserId() async {
    return _userId;
  }
}
