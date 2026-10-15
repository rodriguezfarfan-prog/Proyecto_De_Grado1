import 'package:dartz/dartz.dart';
import 'package:fin_up_project/core/errors/failure.dart';
import '../entities/egreso.dart';

abstract class EgresoRepository {
  Future<Either<Failure, List<Egreso>>> obtenerEgresos();
  Future<Either<Failure, Unit>> guardarEgreso(Egreso egreso);
  Future<Either<Failure, Unit>> actualizarEgreso(Egreso egreso);
  Future<Either<Failure, Unit>> eliminarEgreso(String id);
}
