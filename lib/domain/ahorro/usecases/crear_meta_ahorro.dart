import 'package:dartz/dartz.dart';
import 'package:fin_up_project/core/usecase.dart';
import 'package:fin_up_project/core/errors/failure.dart';
import 'package:fin_up_project/core/value_objects/monto.dart';
import 'package:fin_up_project/domain/ahorro/entities/meta_ahorro.dart';
import 'package:fin_up_project/domain/ahorro/repositories/meta_ahorro_repository.dart';

class CrearMetaAhorroParams {
  final String nombre;
  final double montoObjetivo;
  final double montoActual;
  final int meses;
  final String? descripcion;

  const CrearMetaAhorroParams({
    required this.nombre,
    required this.montoObjetivo,
    required this.montoActual,
    required this.meses,
    this.descripcion,
  });
}

class CrearMetaAhorro implements UseCase<Unit, CrearMetaAhorroParams> {
  final MetaAhorroRepository repository;
  CrearMetaAhorro(this.repository);

  @override
  Future<Either<Failure, Unit>> call(CrearMetaAhorroParams params) {
    final meta = MetaAhorro.crear(
      nombre: params.nombre,
      montoObjetivo: Monto(params.montoObjetivo),
      montoActual: Monto(params.montoActual),
      meses: params.meses,
      descripcion: params.descripcion,
    );
    return repository.guardarMeta(meta);
  }
}
