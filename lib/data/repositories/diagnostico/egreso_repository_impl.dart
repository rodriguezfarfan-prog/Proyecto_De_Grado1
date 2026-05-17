import 'package:dartz/dartz.dart';
import '/core/errors/failure.dart';
import '/data/datasources/remote/remote_egreso_datasource.dart';
import '/data/models/egreso_model.dart';
import '/domain/diagnostico/entities/egreso.dart';
import '/domain/diagnostico/repositories/egreso_repository.dart';

class EgresoRepositoryImpl implements EgresoRepository {
  final RemoteEgresoDataSource remoteDataSource;

  EgresoRepositoryImpl(this.remoteDataSource);

  static const String userId = 'USER_UUID_DE_PRUEBA';

  @override
  Future<Either<Failure, List<Egreso>>> obtenerEgresos() async {
    try {
      final models = await remoteDataSource.fetchEgresos(userId);
      final entities = models.map((m) => m.toDomain()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure('Error al obtener egresos: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> guardarEgreso(Egreso egreso) async {
    try {
      final model = EgresoModel(
        id: egreso.id,
        usuarioId: userId,
        monto: egreso.monto.valor,
        fecha: egreso.fecha.fecha.toIso8601String(),
        descripcion: egreso.descripcion,
        categoria: egreso.categoria.name,
        recurrente: egreso.recurrente,
      );
      await remoteDataSource.createEgreso(model);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Error al guardar egreso: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> eliminarEgreso(String id) async {
    try {
      await remoteDataSource.deleteEgreso(id);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Error al eliminar egreso: $e'));
    }
  }
}