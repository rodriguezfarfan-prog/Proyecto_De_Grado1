import 'package:dartz/dartz.dart';
import '/core/errors/failure.dart';
import '../entities/ingreso.dart';

abstract class IngresoRepository {
  Future<Either<Failure, List<Ingreso>>> obtenerIngresos();
  Future<Either<Failure, Unit>> guardarIngreso(Ingreso ingreso);
  Future<Either<Failure, Unit>> eliminarIngreso(String id);
}