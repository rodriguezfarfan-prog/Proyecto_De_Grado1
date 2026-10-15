import 'package:dartz/dartz.dart';
import 'package:fin_up_project/core/errors/failure.dart';
import 'package:fin_up_project/data/datasources/remote/remote_meta_ahorro_datasource.dart';
import 'package:fin_up_project/data/models/meta_ahorro_model.dart';
import 'package:fin_up_project/domain/ahorro/entities/meta_ahorro.dart';
import 'package:fin_up_project/domain/ahorro/repositories/meta_ahorro_repository.dart';
import 'package:fin_up_project/domain/usuario/repositories/auth_repository.dart';

class MetaAhorroRepositoryImpl implements MetaAhorroRepository {
  final RemoteMetaAhorroDataSource remoteDataSource;
  final AuthRepository authRepository;

  MetaAhorroRepositoryImpl(this.remoteDataSource, this.authRepository);

  @override
  Future<Either<Failure, List<MetaAhorro>>> obtenerMetas() async {
    try {
      final userId = await authRepository.obtenerUserId();
      if (userId == null) return Left(ServerFailure('No hay sesión activa'));
      final models = await remoteDataSource.fetchMetas(userId);
      return Right(models.map((m) => m.toDomain()).toList());
    } catch (e) {
      return Left(ServerFailure('Error al obtener metas: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> guardarMeta(MetaAhorro meta) async {
    try {
      final userId = await authRepository.obtenerUserId();
      if (userId == null) return Left(ServerFailure('No hay sesión activa'));
      final model = MetaAhorroModel(
        id: meta.id,
        usuarioId: userId,
        nombre: meta.nombre,
        montoObjetivo: meta.montoObjetivo.valor,
        montoActual: meta.montoActual.valor,
        abonoMensualFijo: meta.abonoMensualFijo, // ← NUEVO
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

  @override
  Future<Either<Failure, Unit>> agregarAbono(String id, double monto) async {
    try {
      await remoteDataSource.agregarAbono(id, monto);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Error al agregar abono: $e'));
    }
  }
}
