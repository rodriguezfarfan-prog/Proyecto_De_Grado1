import 'package:dartz/dartz.dart';
import '/core/errors/failure.dart';
import '/data/datasources/remote/remote_meta_ahorro_datasource.dart';
import '/data/models/meta_ahorro_model.dart';
import '/domain/ahorro/entities/meta_ahorro.dart';
import '/domain/ahorro/repositories/meta_ahorro_repository.dart';

class MetaAhorroRepositoryImpl implements MetaAhorroRepository {
  final RemoteMetaAhorroDataSource remoteDataSource;
  MetaAhorroRepositoryImpl(this.remoteDataSource);

  static const String userId = 'USER_UUID_DE_PRUEBA';

  @override
  Future<Either<Failure, List<MetaAhorro>>> obtenerMetas() async {
    try {
      final models = await remoteDataSource.fetchMetas(userId);
      return Right(models.map((m) => m.toDomain()).toList());
    } catch (e) {
      return Left(ServerFailure('Error al obtener metas: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> guardarMeta(MetaAhorro meta) async {
    try {
      final model = MetaAhorroModel(
        id: meta.id,
        usuarioId: userId,
        nombre: meta.nombre,
        montoObjetivo: meta.montoObjetivo.valor,
        montoActual: meta.montoActual.valor,
        fechaLimite: meta.fechaLimite.toIso8601String(),
        descripcion: meta.descripcion,
      );
      await remoteDataSource.createMeta(model);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Error al guardar meta: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> eliminarMeta(String id) async {
    try {
      await remoteDataSource.deleteMeta(id);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Error al eliminar meta: $e'));
    }
  }
}