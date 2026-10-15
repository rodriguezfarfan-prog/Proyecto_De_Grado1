import 'package:dartz/dartz.dart';
import 'package:fin_up_project/core/usecase.dart';
import 'package:fin_up_project/core/errors/failure.dart';
import 'package:fin_up_project/domain/diagnostico/entities/diagnostico_resultado.dart';
import 'package:fin_up_project/domain/diagnostico/repositories/ingreso_repository.dart';
import 'package:fin_up_project/domain/diagnostico/repositories/egreso_repository.dart';
import 'calcular_diagnostico.dart';

class RealizarDiagnostico extends UseCase<DiagnosticoResultado, NoParams> {
  final IngresoRepository ingresoRepo;
  final EgresoRepository egresoRepo;

  RealizarDiagnostico(this.ingresoRepo, this.egresoRepo);

  @override
  Future<Either<Failure, DiagnosticoResultado>> call(NoParams params) async {
    final ingresosEither = await ingresoRepo.obtenerIngresos();
    final egresosEither = await egresoRepo.obtenerEgresos();

    return ingresosEither.fold(
      (failure) => Left(failure),
      (ingresos) => egresosEither.fold(
        (failure) => Left(failure),
        (egresos) => Right(CalcularDiagnostico.calcular(ingresos, egresos)),
      ),
    );
  }
}
