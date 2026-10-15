import 'package:dartz/dartz.dart';
import '/core/usecase.dart';
import '/core/errors/failure.dart';
import '/domain/ahorro/repositories/meta_ahorro_repository.dart';

class EliminarMetaParams {
  final String id;
  const EliminarMetaParams(this.id);
}

class EliminarMetaAhorro implements UseCase<Unit, EliminarMetaParams> {
  final MetaAhorroRepository repository;
  EliminarMetaAhorro(this.repository);

  @override
  Future<Either<Failure, Unit>> call(EliminarMetaParams params) {
    return repository.eliminarMeta(params.id);
  }
}
