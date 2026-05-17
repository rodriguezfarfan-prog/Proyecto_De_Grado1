import 'package:dartz/dartz.dart';
import '/core/errors/failure.dart';
import '/data/datasources/remote/remote_usuario_datasource.dart';
import '/domain/usuario/entities/usuario.dart';
import '/domain/usuario/repositories/usuario_repository.dart';

class UsuarioRepositoryImpl implements UsuarioRepository {
  final RemoteUsuarioDataSource remoteDataSource;

  UsuarioRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Usuario>> obtenerUsuarioActual() async {
    try {
      final model = await remoteDataSource.fetchUsuarioActual();
      return Right(model.toDomain());
    } catch (e) {
      return Left(ServerFailure('Error al obtener usuario: $e'));
    }
  }
}