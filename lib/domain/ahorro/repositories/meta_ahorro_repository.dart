import 'package:dartz/dartz.dart';
import 'package:fin_up_project/core/errors/failure.dart';
import '../entities/meta_ahorro.dart';

abstract class MetaAhorroRepository {
  Future<Either<Failure, List<MetaAhorro>>> obtenerMetas();
  Future<Either<Failure, Unit>> guardarMeta(MetaAhorro meta);
  Future<Either<Failure, Unit>> eliminarMeta(String id);
  Future<Either<Failure, Unit>> agregarAbono(String id, double monto);
}
