import 'package:dartz/dartz.dart';
import 'package:fin_up_project/core/errors/failure.dart';
import 'package:fin_up_project/data/datasources/remote/remote_egreso_datasource.dart';
import 'package:fin_up_project/data/models/egreso_model.dart';
import 'package:fin_up_project/domain/diagnostico/entities/egreso.dart';
import 'package:fin_up_project/domain/diagnostico/repositories/egreso_repository.dart';
import 'package:fin_up_project/domain/usuario/repositories/auth_repository.dart';

class EgresoRepositoryImpl implements EgresoRepository {
  final RemoteEgresoDataSource remoteDataSource;
  final AuthRepository authRepository;

  EgresoRepositoryImpl(this.remoteDataSource, this.authRepository);

  @override
  Future<Either<Failure, List<Egreso>>> obtenerEgresos() async {
    try {
      final userId = await authRepository.obtenerUserId();
      if (userId == null) return Left(ServerFailure('No hay sesión activa'));
      final models = await remoteDataSource.fetchEgresos(userId);
      return Right(models.map((m) => m.toDomain()).toList());
    } catch (e) {
      return Left(ServerFailure('Error al obtener egresos: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> guardarEgreso(Egreso egreso) async {
    try {
      final userId = await authRepository.obtenerUserId();
      if (userId == null) return Left(ServerFailure('No hay sesión activa'));
      final model = EgresoModel(
        id: egreso.id,
        usuarioId: userId,
        monto: egreso.monto.valor,
        fecha: egreso.fecha.fecha.toIso8601String(),
        descripcion: egreso.descripcion,
        grupo: egreso.grupo.name,
        subcategoria: egreso.subcategoria,
        recurrente: egreso.recurrente,
      );
      await remoteDataSource.createEgreso(model);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Error al guardar egreso: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> actualizarEgreso(Egreso egreso) async {
    try {
      final userId = await authRepository.obtenerUserId();
      if (userId == null) return Left(ServerFailure('No hay sesión activa'));
      final model = EgresoModel(
        id: egreso.id,
        usuarioId: userId,
        monto: egreso.monto.valor,
        fecha: egreso.fecha.fecha.toIso8601String(),
        descripcion: egreso.descripcion,
        grupo: egreso.grupo.name,
        subcategoria: egreso.subcategoria,
        recurrente: egreso.recurrente,
      );
      await remoteDataSource.updateEgreso(model);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Error al actualizar egreso: $e'));
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
