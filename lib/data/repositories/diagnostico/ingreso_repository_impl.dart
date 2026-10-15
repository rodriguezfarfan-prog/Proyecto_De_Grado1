import 'package:dartz/dartz.dart';
import 'package:fin_up_project/core/errors/failure.dart';
import 'package:fin_up_project/data/datasources/remote/remote_ingreso_datasource.dart';
import 'package:fin_up_project/data/models/ingreso_model.dart';
import 'package:fin_up_project/domain/diagnostico/entities/ingreso.dart';
import 'package:fin_up_project/domain/diagnostico/repositories/ingreso_repository.dart';
import 'package:fin_up_project/domain/usuario/repositories/auth_repository.dart';

class IngresoRepositoryImpl implements IngresoRepository {
  final RemoteIngresoDataSource remoteDataSource;
  final AuthRepository authRepository;

  IngresoRepositoryImpl(this.remoteDataSource, this.authRepository);

  @override
  Future<Either<Failure, List<Ingreso>>> obtenerIngresos() async {
    try {
      final userId = await authRepository.obtenerUserId();
      if (userId == null) return Left(ServerFailure('No hay sesión activa'));
      final models = await remoteDataSource.fetchIngresos(userId);
      return Right(models.map((m) => m.toDomain()).toList());
    } catch (e) {
      return Left(ServerFailure('Error al obtener ingresos: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> guardarIngreso(Ingreso ingreso) async {
    try {
      final userId = await authRepository.obtenerUserId();
      if (userId == null) return Left(ServerFailure('No hay sesión activa'));
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
  Future<Either<Failure, Unit>> actualizarIngreso(Ingreso ingreso) async {
    try {
      final userId = await authRepository.obtenerUserId();
      if (userId == null) return Left(ServerFailure('No hay sesión activa'));
      final model = IngresoModel(
        id: ingreso.id,
        usuarioId: userId,
        monto: ingreso.monto.valor,
        fecha: ingreso.fecha.fecha.toIso8601String(),
        descripcion: ingreso.descripcion,
        tipo: ingreso.tipo.name,
      );
      await remoteDataSource.updateIngreso(model);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Error al actualizar ingreso: $e'));
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
