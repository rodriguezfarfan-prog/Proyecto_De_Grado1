import 'package:dartz/dartz.dart';
import '/core/usecase.dart';
import '/core/errors/failure.dart';
import '/domain/ahorro/repositories/meta_ahorro_repository.dart';

class AgregarAbonoParams {
  final String id;
  final double monto;
  const AgregarAbonoParams({required this.id, required this.monto});
}

class AgregarAbonoMeta implements UseCase<Unit, AgregarAbonoParams> {
  final MetaAhorroRepository repository;
  AgregarAbonoMeta(this.repository);

  @override
  Future<Either<Failure, Unit>> call(AgregarAbonoParams params) {
    return repository.agregarAbono(params.id, params.monto);
  }
}
