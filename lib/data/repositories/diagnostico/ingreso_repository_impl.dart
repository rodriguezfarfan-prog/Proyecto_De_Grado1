import 'package:dartz/dartz.dart';
import '/core/errors/failure.dart';
import '/data/datasources/remote/remote_ingreso_datasource.dart';
import '/data/models/ingreso_model.dart';
import '/domain/diagnostico/entities/ingreso.dart';
import '/domain/diagnostico/repositories/ingreso_repository.dart';

class IngresoRepositoryImpl implements IngresoRepository {
  final RemoteIngresoDataSource remoteDataSource;

  IngresoRepositoryImpl(this.remoteDataSource);

  // ID de usuario mock (en producción vendrá de la sesión)
  static const String userId = 'USER_UUID_DE_PRUEBA';

  @override
  Future<Either<Failure, List<Ingreso>>> obtenerIngresos() async {
    try {
      final models = await remoteDataSource.fetchIngresos(userId);
      final entities = models.map((m) => m.toDomain()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure('Error al obtener ingresos: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> guardarIngreso(Ingreso ingreso) async {
    try {
      final model = IngresoModel(
        id: ingreso.id,
        usuarioId: userId,
        monto: ingreso.monto.valor,
        fecha: ingreso.fecha.fecha.toIso8601String(),
        descripcion: ingreso.descripcion,
        tipo: ingreso.tipo.name,
      );
      await remoteDataSource.createIngreso(model);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Error al guardar ingreso: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> eliminarIngreso(String id) async {
    try {
      await remoteDataSource.deleteIngreso(id);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Error al eliminar ingreso: $e'));
    }
  }
}